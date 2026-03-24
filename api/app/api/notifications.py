import uuid
from pathlib import Path
from fastapi import APIRouter, Depends, HTTPException, status,Query,File,UploadFile,Form
from sqlalchemy.orm import Session,joinedload
from app.core.database import get_db
from app.models.notification import Notification
from app.models.user import User
from app.schemas.notification import (
    SOSNotificationCreate,
    SOSNotificationResponse,
    NearbyNotificationItem,
    NearbyNotificationsResponse,
    NotificationDetailResponse,
    NotificationStatusUpdate,
    StatusUpdateResponse,
    ResolvedByUser,
    NotificationUpdate,
    LocationResponse
)

from app.models.notification_follower import NotificationFollower
from app.schemas.follower import FollowerResponse,FollowersListResponse
from app.utils.security import get_admin_user,get_current_user
from typing import Optional,List
from sqlalchemy import text, func, case 
from app.models.status import Status
from app.models.category import Category
from app.models.admin_note import AdminNote
from app.schemas.admin_note import AdminNoteCreate,AdminNoteResponse,AdminNotesListResponse
from app.models.notification_photo import NotificationPhoto
from app.models.status_history import StatusHistory


async def save_notification_image(
    file:UploadFile,
    notification_id:int
)->str:
    
    """
    Bildirim fotoğrafını kaydet
    
    Args:
    - file:Upload edilen dosya
    - notification_id:Bildirim ID
    
    Returns:
    - Kaydedilen dosyanın path'i (/upload/notifications/123/abc.jpg)
    
    Yüklenen dosyaları çakışma olmaması için uuid ile isimlendirir ve ilgili bildirim klasörüne fiziksel olarak kaydeder.
    
    """

    upload_dir=Path(f"uploads/notifications/{notification_id}")

    upload_dir.mkdir(parents=True,exist_ok=True) 

    file_ext=file.filename.split(".")[-1]
    unique_filename=f"{uuid.uuid4().hex[:12]}.{file_ext}"
    file_path=upload_dir/unique_filename

    content=await file.read()
    with open(file_path,"wb") as f:
        f.write(content)

    return f"/uploads/notifications/{notification_id}/{unique_filename}"


def check_sos_rate_limit(user_id:int,db:Session):

    """
    SOS rate limit kontrolü (3 SOS / 24 saat / kullanıcı)

    Args:
        user_id: Kullanıcı ID
        db: Database session

    Raises:
        HTTPException: Rate limit aşıldığında (429)
    """    

    from datetime import datetime,timedelta

    twenty_four_hours_ago=datetime.now()-timedelta(hours=24)

    sos_count=db.query(Notification).filter(
        Notification.user_id==user_id,
        Notification.is_sos, 
        Notification.created_at>=twenty_four_hours_ago,
        Notification.deleted_at.is_(None)
    ).count() 

    if sos_count>=3:
        oldest_sos_notification=db.query(Notification).filter(
            Notification.user_id==user_id,
            Notification.is_sos,
            Notification.deleted_at.is_(None)
        ).order_by(Notification.created_at.asc()).first() 

        retry_after=oldest_sos_notification.created_at+timedelta(hours=24) 

        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS, 
            detail={
                "code":"SOS_RATE_LIMIT_EXCEEDED",
                "message":"24 saat içinde en fazla 3 SOS bildirimi gönderebilirsiniz",
                "retry_after":retry_after.isoformat()
            }
        )

router=APIRouter(prefix="/notifications",tags=["Notifications"])

@router.patch("/{notification_id}", response_model=dict)
def update_notification(
    notification_id: int,
    update_data: NotificationUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Bildirim güncelle (Başlık / Açıklama)
    Sadece sahibi güncelleyebilir.
    """
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.deleted_at.is_(None)
    ).first()

    if not notification:
        raise HTTPException(status_code=404, detail={"message": "Bildirim bulunamadı"})

    if notification.user_id != current_user.id and current_user.role != 'admin' and not current_user.is_super_admin:
        raise HTTPException(status_code=403, detail={"message": "Bu işlem için yetkiniz yok"})

    if update_data.title:
        notification.title = update_data.title
    if update_data.description:
        notification.description = update_data.description
    
    db.commit()
    
    notification = db.query(Notification).options(
        joinedload(Notification.status),
        joinedload(Notification.category),
        joinedload(Notification.notification_photos)
    ).filter(Notification.id == notification_id).first()
    
    if notification:
        notification.location = None
    
    notification.status_name = notification.status.display_name if notification.status else "Bilinmiyor"
    notification.category_name = notification.category.display_name if notification.category else "Bilinmiyor"
    notification.photos = [p.s3_url for p in notification.notification_photos] if notification.notification_photos else []
    
    return {
        "success": True,
        "message": "Bildirim güncellendi",
        "data": NotificationDetailResponse.model_validate(notification).model_dump()
    }



@router.get("",response_model=dict,status_code=status.HTTP_200_OK)
def get_notifications(
    page:int=Query(1,ge=1,description="Sayfa numarası"),
    per_page:int=Query(20,ge=1,le=100,
    description="Sayfa başına bildirim"),
    
    category_id:Optional[int]=Query(None,ge=1,le=5,description="Kategori filtresi"),
    status_id:Optional[int]=Query(None,ge=1,le=4,description="Durum filtresi"),
    search:Optional[str]=Query(None,description="Başlık/açıklama ara"),

    latitude:Optional[float]=Query(None,ge=-90,le=90,description="Kullanıcı enlemi"),
    longitude:Optional[float]=Query(None,ge=-180,le=180,description="Kullanıcı boylamı"),
    distance:Optional[int]=Query(None,ge=100,le=50000,description="Mesafe (metre)"),

    sort_by:str=Query("created_at",description="Sıralama alanı"),
    order:str=Query("desc",regex="^(asc|desc)$",description="Sıralama yönü"),

    current_user:User=Depends(get_current_user),

    db:Session=Depends(get_db)):
    
    """
    **Kampüs Bildirimlerini Listele ve Filtrele**

    Bu uç nokta, kampüs genelindeki tüm bildirimleri çeşitli kriterlere göre getirir.
    
    - **Sayfalama (Pagination):** `page` ve `per_page` ile veriler parça parça çekilir.
    - **Filtreleme:** - `category_id`: (1: Acil, 2: Arıza, 3: Güvenlik, 4: Kayıp Eşya, 5: Etkinlik)
        - `status_id`: (1: Beklemede, 2: İncelemede, 3: Çözüldü, 4: Reddedildi)
    - **Konum Bazlı Arama:** `latitude`, `longitude` ve `distance` (metre) parametreleri birlikte gönderilirse, belirtilen yarıçap içindeki bildirimler filtrelenir.
    - **Sıralama:** `sort_by` (created_at, title) ve `order` (asc, desc) ile liste düzenlenir.
    """
    query=db.query(Notification).options(joinedload(Notification.user),
    joinedload(Notification.category),
    joinedload(Notification.status)).filter(Notification.deleted_at.is_(None))
    
    if category_id: 
        query=query.filter(Notification.category_id==category_id) 

    if status_id:
        query=query.filter(Notification.status_id==status_id) 

    if search:
        query=query.filter(
            text("title LIKE :search_term OR description LIKE :search_term").params(search_term=f"%{search}%")
        ) 

    if latitude is not None and longitude is not None and distance: 

        query=query.filter(
            text(
                "location.STDistance(geography::STGeomFromText(:wkt,4326))<= :dist"
            ).bindparams(
                wkt=f"POINT({longitude} {latitude})",
                dist=distance
            )
        )

    total_items=query.count() 

    if sort_by=="created_at":
        sort_column=Notification.created_at
    elif sort_by=="title":
        sort_column=Notification.title
    elif sort_by=="status_id":
        sort_column=Notification.status_id
    else:
        sort_column=Notification.created_at

    if order=="desc":
        query=query.order_by(sort_column.desc())
    else:
        query=query.order_by(sort_column.asc())

    offset=(page-1)*per_page
    notifications=query.offset(offset).limit(per_page).all()

    total_pages=(total_items+per_page-1)//per_page

    return {
        "success":True,
        "data":{
            "notifications":[
                {
                    "id":n.id,
                    "user_id":n.user.id,
                    "user_email":n.user.email,
                    "user_first_name":n.user.first_name,
                    "user_last_name":n.user.last_name,
                    "category_id":n.category_id,
                    "category_name":n.category.display_name,
                    "status_id":n.status_id,
                    "status_name":n.status.display_name,
                    "title":n.title,
                    "description":n.description,
                    "address":n.address,
                    "is_sos":n.is_sos,
                    "is_high_priority":n.is_high_priority,
                    "created_at":n.created_at.isoformat(),
                }
                for n in notifications 
            ]
        },
        "pagination":{
            "current_page":page,
            "per_page":per_page,
            "total_pages":total_pages,
            "total_items":total_items,
        },
        "message":f"{total_items} bildirim bulundu"
    }    

    
@router.get("/nearby")
def get_nearby_notifications(
    latitude:float=Query(...,ge=-90,le=90,description="Kullanıcı enlemi"),
    longitude:float=Query(...,ge=-180,le=180,description="Kullanıcı boylamı"),
    radius:int=Query(1000,ge=100,le=10000,description="Yarıçap (metre)"),
    category_id:Optional[int]=Query(None,ge=1,le=5),
    status_id:Optional[int]=Query(None,ge=1,le=4),
    limit:int=Query(50,ge=1,le=100),
    current_user:User=Depends(get_current_user),
    db:Session=Depends(get_db)
):

    """
    **Harita Görünümü İçin Yakındaki Bildirimler**

    Kullanıcının harita üzerinde bulunduğu merkeze göre en yakın bildirimleri mesafeye göre sıralı getirir.
    
    - **Teknik Detay:** Performans optimizasyonu amacıyla MSSQL `geography::STDistance` fonksiyonu kullanılarak veritabanı seviyesinde mesafe hesaplaması yapılır.
    - **Kullanım:** Flutter harita ekranında marker (işaretçi) basmak için optimize edilmiş veri yapısı döner.
    - **Sınır:** `radius` parametresi metre cinsinden kapsama alanını belirler (Maks: 10.000m).
    """

    result=db.execute(text("""
        SELECT
            n.id,
            n.title,
            n.description,
            n.category_id,
            c.display_name AS category_name,
            n.status_id,
            s.display_name AS status_name,
            n.location.Lat AS latitude,
            n.location.Long AS longitude,
            n.location.STDistance(geography::STGeomFromText('POINT(' + CAST(:user_long AS VARCHAR) + ' ' + CAST(:user_lat AS VARCHAR) + ')', 4326)) AS distance_meters,
            n.is_sos,
            n.created_at
        FROM notifications n
        INNER JOIN categories c ON n.category_id = c.id
        INNER JOIN statuses s ON n.status_id = s.id
        WHERE n.deleted_at IS NULL
          AND n.location.STDistance(geography::STGeomFromText('POINT(' + CAST(:user_long AS VARCHAR) + ' ' + CAST(:user_lat AS VARCHAR) + ')', 4326)) <= :radius
          AND (:category_id IS NULL OR n.category_id=:category_id)
          AND (:status_id IS NULL OR n.status_id = :status_id)
        ORDER BY distance_meters ASC
        OFFSET 0 ROWS FETCH NEXT :limit ROWS ONLY
        """),{
            "user_lat":latitude,
            "user_long":longitude,
            "radius":radius,
            "category_id":category_id,
            "status_id":status_id,
            "limit":limit
    })

    notifications=[]

    for row in result:
        notifications.append(NearbyNotificationItem(
            id=row.id,
            title=row.title,
            description=row.description,
            category_id=row.category_id,
            category_name=row.category_name,
            status_id=row.status_id,
            status_name=row.status_name,
            latitude=float(row.latitude),
            longitude=float(row.longitude),
            distance_meters=float(row.distance_meters),
            is_sos=row.is_sos,
            created_at=row.created_at
        ))

    return {
        "success":True,
        "data":NearbyNotificationsResponse(
            notifications=notifications,
            count=len(notifications),
            center={"latitude":latitude,"longitude":longitude},
            radius_meters=radius
        ).model_dump(),
    }


@router.get("/{notification_id}",response_model=dict,status_code=status.HTTP_200_OK)
def get_notification_detail(
    notification_id:int,
    current_user:User=Depends(get_current_user),
    db:Session=Depends(get_db)):
    
    """
    Tek Bildirim Detayı

    PATH PARAMETERS:
    -notification_id:Bildirim ID

    RESPONSE:
    -bildirim detayları

    ERRORS:
    -404:Bildirim Bulunamadı
    -404:Bildirim Silinmiş

    """

    notification=db.query(Notification).options(
        joinedload(Notification.user),
        joinedload(Notification.category),
        joinedload(Notification.status),
        joinedload(Notification.notification_photos),
        joinedload(Notification.resolved_by_user),
        joinedload(Notification.admin_notes)
    ).filter(
        Notification.id==notification_id
    ).first()

    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code":"NOTIFICATION_NOT_FOUND",
                "message":"Bildirim bulunamadı"
            }
        )

    if notification.deleted_at is not None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code":"NOTIFICATION_DELETED",
                "message":"Bu bildirim silinmiş"
            }
        )           

    is_following = db.query(NotificationFollower).filter(
        NotificationFollower.notification_id == notification_id,
        NotificationFollower.user_id == current_user.id
    ).first() is not None
    
    notification.is_following = is_following
    
    notification.status_name = notification.status.display_name if notification.status else "Bilinmiyor"
    notification.category_name = notification.category.display_name if notification.category else "Diğer"
    notification.photos = [p.s3_url for p in notification.notification_photos]
    
    notification.location = None

    # 1. Pydantic modelini oluşturup hemen DİCT (sözlük) formatına çeviriyoruz.
    notification_dict = NotificationDetailResponse.model_validate(notification).model_dump()
    
    try:
        # 2. MSSQL'den koordinatları güvenli bir şekilde çekiyoruz
        loc_query = text("SELECT location.Lat, location.Long FROM notifications WHERE id=:id")
        result = db.execute(loc_query, {"id": notification_id}).fetchone()
        
        if result and result[0] is not None and result[1] is not None:
            # 3. Sözlüğe konumu manuel ekliyoruz ki JSON'da kesinlikle yer alsın!
            notification_dict["location"] = {
                "latitude": float(result[0]),
                "longitude": float(result[1]),
                "address": notification.address
            }
            # Flutter'daki "kurşun geçirmez" okuyucumuz için ana dizine de koyalım
            notification_dict["latitude"] = float(result[0])
            notification_dict["longitude"] = float(result[1])
            
    except Exception as e:
        # Eğer bir hata olursa terminalde görelim, sessizce geçiştirmesin
        print(f"Konum çekilirken backend hatası: {e}") 
        pass

    return {
        "success": True,
        "data": notification_dict,
        "message": "Bildirim detayları getirildi."
    }

@router.post("",response_model=dict,status_code=status.HTTP_201_CREATED)
async def create_notification(
    category_id:int=Form(...,ge=1,le=5),
    title:str=Form(...,min_length=5,max_length=80),
    description:str=Form(...,min_length=10,max_length=500),
    latitude:float=Form(...,ge=-90,le=90),
    longitude:float=Form(...,ge=-180,le=180),
    address:str=Form(...,min_length=1,max_length=300),
    is_sos:bool=Form(default=False),
    
    images: List[UploadFile] = File(default=[]),

    current_user:User=Depends(get_current_user),
    db:Session=Depends(get_db)):

    """
    Yeni Bildirim Oluştur

    FORM DATA:
    - category_id:Kategori (1-5)
    - title : Başlık
    - description : Açıklama
    - latitude: Enlem
    - longitude : Boylam
    - address : Adres
    - is_sos : Sos bildirimi mi ? (Opsiyonel)
    - images : Fotoğraflar (Opsiyonel max 5)

    Bir bildirim için en fazla 5 adet görsel yüklenebilir. Desteklenen formatlar: JPG, PNG.

    """

    location_wkt=f"POINT({longitude} {latitude})"

    is_high_priority=is_sos

    db.execute(text("""
        SET NOCOUNT ON;
        INSERT INTO notifications
        (user_id, category_id, status_id, title, description, location, address, is_sos, is_high_priority)
        VALUES
        (:user_id, :category_id, :status_id, :title, :description,
        geography::STGeomFromText(:wkt, 4326), :address, :is_sos, :is_high_priority)
    """),
        {
            "user_id": current_user.id,
            "category_id": category_id,
            "status_id": 1,
            "title": title.strip(),
            "description": description.strip(),
            "wkt": location_wkt,
            "address": address.strip(),
            "is_sos": is_sos,
            "is_high_priority": is_high_priority
        }
    )
    
    new_notification_id = db.execute(text("""
        SELECT TOP 1 id FROM notifications 
        WHERE user_id = :user_id 
        ORDER BY id DESC
    """), {"user_id": current_user.id}).scalar()

    db.commit()
    uploaded_images=[]

    if images: 
        for idx ,image in enumerate(images[:5]):
            if image.content_type not in ["image/jpeg",
            "image/jpg","image/png"]:
                continue
            
            file_path=await save_notification_image(image,new_notification_id)
            
            photo=NotificationPhoto(
                notification_id=new_notification_id,
                s3_key=file_path,
                s3_url=f"http://localhost:8000{file_path}",
                file_size_bytes=image.size,
                mime_type=image.content_type,
                display_order=idx+1
            )
            db.add(photo)

            uploaded_images.append({
                "path":file_path,
                "url":f"http://localhost:8000{file_path}",
                "order":idx+1
            })

    db.commit()        

    return {
        "success":True,
        "data":{
            "id":new_notification_id,
            "title":title.strip(),
            "status_id":1,
            "images":uploaded_images,
        },
        "message":"Bildirim başarıyla oluşturuldu"        
    }


@router.patch("/{notification_id}/status",
response_model=dict,status_code=status.HTTP_200_OK)
def update_notification_status(
    notification_id:int,
    status_update:NotificationStatusUpdate,
    admin_user:User=Depends(get_admin_user),
    db:Session=Depends(get_db)):

    """
    Bildirim durumu güncelle (Admin only)
    
    PATH PARAMETERS:
    - notification_id: Bildirim ID
    
    REQUEST BODY:
    - status_id: Yeni durum (1-4)
    
    RESPONSE:
    - Güncellenmiş bildirim bilgileri
    - Status history kaydı
    
    ERRORS:
    - 404: Bildirim bulunamadı
    - 400: Zaten çözülmüş
    - 403: Admin yetkisi gerekli
    """

    notification=db.query(Notification).filter(
        Notification.id==notification_id,
        Notification.deleted_at.is_(None)
    ).first()  
 
    if not notification: 
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code":"NOTIFICATION_NOT_FOUND",
                "message":"Bildirim bulunamadı"
            }
        )

    try:
        old_status_id = notification.status_id
        notification.status_id = status_update.status_id
        notification.updated_at = func.now()
        
        if status_update.status_id == 3:
            notification.resolved_at = func.now()
            notification.resolved_by_user_id = admin_user.id
        else:
            notification.resolved_at = None
            notification.resolved_by_user_id = None
            
        new_history = StatusHistory(
            notification_id=notification.id,
            old_status_id=old_status_id,
            new_status_id=status_update.status_id,
            changed_by_user_id=admin_user.id,
            changed_at=func.now()
        )
        db.add(new_history)
        
        db.commit()
        db.refresh(notification)

    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

    status_info = db.query(Status).filter(Status.id == notification.status_id).first()

    resonse_data=StatusUpdateResponse(
        id=notification.id,
        status_id=notification.status_id,
        status_name=status_info.display_name if status_info else None,
        resolved_at=notification.resolved_at,
        resolved_by_user_id=notification.resolved_by_user_id,
        resolved_by=ResolvedByUser(
            id=admin_user.id,
            email=admin_user.email,
            first_name=admin_user.first_name,
            last_name=admin_user.last_name
        ) if notification.resolved_by_user_id else None
    )

    return {
        "success":True,
        "data":resonse_data.model_dump(),
        "message":"Bildirim durumu güncellendi"
    }

@router.post("/sos",status_code=201,response_model=dict)
def create_sos_notification(
    sos_data:SOSNotificationCreate,
    current_user:User=Depends(get_current_user),
    db:Session=Depends(get_db)
):  

    """
    SOS bildirimi oluştur (Rate limit:3/24h)

    REQUEST BODY:

    - title: Başlık
    - description: Açıklama
    - latitude , longitude : Konum
    - address : Adres (Opsiyonel)

    RESPONSE:
    - SOS bildirimi bilgileri
    
    ERRORS:
    - 429 : Rate limit aşıldı (3/24h)
    - 422 : Validation hatası
    
    Acil durum hatlarının suistimal edilmesini önlemek adına kullanıcı başına 24 saatlik periyotta 3 adet SOS limiti uygulanmaktadır.
    
    """
    check_sos_rate_limit(current_user.id,db)

    sos_category_id=1    

    db.execute(text("""
        INSERT INTO notifications (
        user_id,
        category_id,
        status_id,
        title,
        description,
        location,
        address,
        is_sos,
        is_high_priority,
        created_at
        )
        VALUES(
        :user_id,:category_id,1,:title,:description,
        geography::STGeomFromText('POINT(' + CAST(:longitude AS VARCHAR(50)) + ' ' + CAST(:latitude AS VARCHAR(50)) + ')', 4326),
        :address,1,1,CURRENT_TIMESTAMP)
    """),
    {
        "user_id":current_user.id,
        "category_id":sos_category_id,
        "title":sos_data.title,
        "description":sos_data.description,
        "latitude":float(sos_data.latitude),
        "longitude":float(sos_data.longitude),
        "address":sos_data.address
    })

    db.commit()

    notification = db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_sos == True
    ).order_by(Notification.created_at.desc()).first()

    if not notification:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Bildirim oluşturulamadı"
        )

    data=SOSNotificationResponse( 
        id=notification.id,
        title=notification.title,
        description=notification.description,
        category_id=notification.category_id,
        status_id=notification.status_id,
        is_sos=notification.is_sos,
        is_high_priority=notification.is_high_priority,
        created_at=notification.created_at
    ).model_dump()

    return{
        "success":True,
        "data":data,
        "message":"SOS bildirimi oluşturuldu"
    }

@router.post("/{notification_id}/follow",status_code=status.HTTP_201_CREATED,response_model=dict)
def follow_notification(
    notification_id:int,
    current_user:User=Depends(get_current_user),
    db:Session=Depends(get_db)
):
    """Bildirimi takip et"""
    
    notification=db.query(Notification).filter(
        Notification.id==notification_id,
        Notification.deleted_at.is_(None)
    ).first()

    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code":"NOT_FOUND",
                "message":"Bildirim bulunamadı"
            }
        )

    existing=db.query(NotificationFollower).filter(
        NotificationFollower.notification_id==notification_id,
        NotificationFollower.user_id==current_user.id
    ).first()

    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "code":"ALREADY_FOLLOWING",
                "message":"Zaten takip ediyorsunuz"
            }
        )
        
    follower=NotificationFollower(
        notification_id=notification_id,
        user_id=current_user.id
    )    

    db.add(follower)
    db.commit()

    return {
        "success":True,
        "message":"Bildirim takip edildi"
    }

@router.delete("/{notification_id}/follow",status_code=status.HTTP_200_OK,response_model=dict)
def unfollow_notification(
    notification_id:int,
    current_user:User=Depends(get_current_user),
    db:Session=Depends(get_db)
):
    """Takibi bırak"""

    follower=db.query(NotificationFollower).filter(
        NotificationFollower.notification_id==notification_id,
        NotificationFollower.user_id==current_user.id
    ).first()

    if not follower:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code":"NOT_FOLLOWING",
                "message":"Bu bildirimi takip etmiyorsunuz"
            }
        )   

    db.delete(follower)
    db.commit()

    return {
        "success":True,
        "message":"Takip bırakıldı"
    }

@router.get("/{notification_id}/followers",status_code=status.HTTP_200_OK,response_model=dict)
def get_notification_followers(
    notification_id:int,
    current_user:User=Depends(get_admin_user),
    db:Session=Depends(get_db)
):
    """
    Bildirimi takip edenleri (admin) listele
    """

    pass 

@router.post("/{notification_id}/notes", response_model=dict, status_code=status.HTTP_201_CREATED)
def add_admin_note(
    notification_id: int,
    note: AdminNoteCreate,
    current_user: User = Depends(get_admin_user),
    db: Session = Depends(get_db)
):
    """
    Admin notu ekle
    """

    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.deleted_at.is_(None)
    ).first()

    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "Bildirim bulunamadı"}
        )

    new_note = AdminNote(
        notification_id=notification_id,
        admin_user_id=current_user.id,
        note_content=note.note_content
    )
    
    db.add(new_note)
    db.commit()
    db.refresh(new_note)

    return {
        "success": True,
        "data": {
            "id": new_note.id,
            "notification_id": new_note.notification_id,
            "admin_user_id": new_note.admin_user_id,
            "admin_name": f"{current_user.first_name} {current_user.last_name}",
            "note_content": new_note.note_content,
            "created_at": new_note.created_at,
            "updated_at": new_note.updated_at
        },
        "message": "Not eklendi"
    }
    
    """Takip edilen bildirimleri listele"""

    notification=db.query(Notification).filter(
        Notification.id==notification_id,
        Notification.deleted_at.is_(None)
    ).first()

    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code":"NOT_FOUND",
                "message":"Bildirim bulunamadı"
            }
        )

    followers=db.query(
        User.id,
        User.email,
        User.first_name,
        User.last_name,
        NotificationFollower.followed_at
    ).join(
        NotificationFollower,
        User.id==NotificationFollower.user_id
    ).filter(
        NotificationFollower.notification_id==notification_id
    ).order_by(
        NotificationFollower.followed_at.desc()
    ).all()    

    follower_list=[
        FollowerResponse(
            id=f.id,
            email=f.email,
            first_name=f.first_name,
            last_name=f.last_name,
            followed_at=f.followed_at
        ) for f in followers
    ]

    response_data=FollowersListResponse(
        total=len(follower_list),
        followers=follower_list
    ).model_dump()

    return {
        "success":True,
        "data":response_data
    }

@router.get("/me/following",status_code=status.HTTP_200_OK,response_model=dict)
def get_my_followed_notifications(
    current_user:User=Depends(get_current_user),
    db:Session=Depends(get_db)
):
    "Kullanıcının takip ettiği bildirimleri listele"

    latest_change_subq = db.query(
        StatusHistory.notification_id,
        func.max(StatusHistory.changed_at).label('latest_change')
    ).join(
        NotificationFollower,
        (StatusHistory.notification_id == NotificationFollower.notification_id) &
        (NotificationFollower.user_id == current_user.id)
    ).filter(
        StatusHistory.changed_at > NotificationFollower.followed_at,
        StatusHistory.changed_by_user_id != current_user.id
    ).group_by(
        StatusHistory.notification_id
    ).subquery()

    followed = db.query(
        Notification.id,
        Notification.title,
        Notification.description,
        Notification.address,
        Notification.category_id,
        Category.name.label('category_name'),
        Category.display_name.label('category_display_name'),
        Category.color_hex.label('category_color'),
        Notification.status_id,
        Status.name.label('status_name'),
        Status.display_name.label('status_display_name'),
        Status.color_hex.label('status_color'),
        NotificationFollower.followed_at,
        latest_change_subq.c.latest_change
    ).join(
        NotificationFollower,
        Notification.id == NotificationFollower.notification_id
    ).join(
        Category,
        Notification.category_id == Category.id
    ).join(
        Status,
        Notification.status_id == Status.id
    ).outerjoin(
        latest_change_subq,
        Notification.id == latest_change_subq.c.notification_id
    ).filter(
        NotificationFollower.user_id == current_user.id,
        Notification.deleted_at.is_(None)
    ).order_by(
      
        case((latest_change_subq.c.latest_change.is_(None), 0), else_=1).desc(),
        latest_change_subq.c.latest_change.desc(),
        NotificationFollower.followed_at.desc()
    ).all()

    followed_list=[
        {
            "id":f.id,
            "title":f.title,
            "description":f.description,
            "address":f.address,
            "category":{
                "id":f.category_id,
                "name":f.category_name,
                "display_name":f.category_display_name,
                "color_hex":f.category_color
            },
            "status":{
                "id":f.status_id,
                "name":f.status_name,
                "display_name":f.status_display_name,
                "color_hex":f.status_color
            },
            "followed_at":f.followed_at.isoformat(),
            "has_updates": db.query(StatusHistory).filter(
                StatusHistory.notification_id == f.id,
                StatusHistory.changed_at > f.followed_at,
                StatusHistory.changed_by_user_id != current_user.id  
            ).count() > 0
        }
        for f in followed
    ]

    return {
        "success":True,
        "total":len(followed_list),
        "data":followed_list
    }

@router.get("/me/following/updates-count", status_code=status.HTTP_200_OK)
def get_following_updates_count(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Takip edilen bildirimlerdeki son durum değişikliği sayısını döndürür.
    Badge için kullanılır.
    """
    
    followed = db.query(
        NotificationFollower.notification_id,
        NotificationFollower.followed_at
    ).filter(
        NotificationFollower.user_id == current_user.id
    ).all()
    
    if not followed:
        return {
            "success": True,
            "data": {"count": 0}
        }
    
    updates_count = 0
    
    for notif_id, followed_at in followed:
        history_count = db.query(StatusHistory).filter(
            StatusHistory.notification_id == notif_id,
            StatusHistory.changed_at > followed_at,
            StatusHistory.changed_by_user_id != current_user.id  
        ).count()
        
        if history_count > 0:
            updates_count += 1
    
    return {
        "success": True,
        "data": {"count": updates_count}
    }

@router.post("/me/following/mark-viewed", status_code=status.HTTP_200_OK)
def mark_following_as_viewed(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Takip edilen bildirimleri 'görüldü' olarak işaretle.
    followed_at tarihini şu ana günceller, böylece sadece bundan sonraki
    değişiklikler badge'de sayılır.
    """
    
    db.query(NotificationFollower).filter(
        NotificationFollower.user_id == current_user.id
    ).update({
        "followed_at": func.now()
    })
    
    db.commit()
    
    return {
        "success": True,
        "message": "Bildirimler görüldü olarak işaretlendi"
    }

@router.post("/{notification_id}/notes",status_code=status.HTTP_201_CREATED,response_model=dict)
def create_admin_note(
    notification_id:int,
    note_data:AdminNoteCreate,
    current_user:User=Depends(get_admin_user),
    db:Session=Depends(get_db)
):
    """Admin notu ekle"""

    notification=db.query(Notification).filter(
        Notification.id==notification_id,
        Notification.deleted_at.is_(None)
    ).first()

    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code":"NOT_FOUND",
                "message":"Bildirim bulunamadı"
            }
        )

    admin_note=AdminNote(
        notification_id=notification_id,
        admin_user_id=current_user.id,
        note_content=note_data.note_content.strip()
    )
    db.add(admin_note)
    db.commit()
    db.refresh(admin_note)

    response_data=AdminNoteResponse(
        id=admin_note.id,
        admin_name=f"{current_user.first_name} {current_user.last_name}",
        notification_id=admin_note.notification_id,
        admin_user_id=admin_note.admin_user_id,
        note_content=admin_note.note_content,
        created_at=admin_note.created_at,
        updated_at=admin_note.updated_at
    ).model_dump()

    return {
        "success":True,
        "data": response_data,
        "message":"Not eklendi"
    }

@router.get("/{notification_id}/notes",status_code=status.HTTP_200_OK,response_model=dict)
def get_admin_notes(
    notification_id:int,
    current_user:User=Depends(get_admin_user),
    db:Session=Depends(get_db)
):
    """Bildirime ait admin notlarını listele"""

    notification=db.query(Notification).filter(
        Notification.id==notification_id,
        Notification.deleted_at.is_(None)
    ).first()

    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code":"NOT_FOUND",
                "message":"Bildirim bulunamadı"
            }
        )

    notes=db.query(
        AdminNote.id,
        AdminNote.notification_id,
        AdminNote.admin_user_id,
        User.first_name,
        User.last_name,
        AdminNote.note_content,
        AdminNote.created_at,
        AdminNote.updated_at
    ).join(
        User,
        AdminNote.admin_user_id==User.id
    ).filter(
        AdminNote.notification_id==notification_id
    ).order_by(
        AdminNote.created_at.desc()
    ).all()

    notes_list=[
            AdminNoteResponse(
                id=n.id,
                notification_id=n.notification_id,
                admin_user_id=n.admin_user_id,
                admin_name=f"{n.first_name} {n.last_name}",
                note_content=n.note_content,
                created_at=n.created_at,
                updated_at=n.updated_at
            ) for n in notes
    ]

    response_data=AdminNotesListResponse(
        total=len(notes_list),
        notes=notes_list
    ).model_dump()
    
    return {
        "success":True,
        "data":response_data
    }

@router.patch("/{notification_id}/notes/{note_id}",status_code=status.HTTP_200_OK,response_model=dict)
def update_admin_note(
    notification_id:int,
    note_id:int,
    note_date:AdminNoteCreate,
    current_user:User=Depends(get_admin_user),
    db:Session=Depends(get_db)
):
    """Admin notunu güncelle (sadece kendi notu)"""

    admin_note=db.query(AdminNote).filter(
        AdminNote.id==note_id,
        AdminNote.notification_id==notification_id,
        AdminNote.admin_user_id==current_user.id
    ).first()

    if not admin_note:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code":"NOT_FOUND",
                "message":"Not bulunamadı veya yetkiniz yok"
            }
        )

    admin_note.note_content=note_date.note_content.strip()

    db.commit()
    db.refresh(admin_note)

    return {
        "success":True,
        "message":"Not güncellendi"
    }

@router.get("/notifications/{notification_id}/history")
def get_status_history(
    notification_id:int,
    current_user:User=Depends(get_current_user),
    db:Session=Depends(get_db)):
    """
    Notification status geçmişini göster
    """    

    history=db.query(StatusHistory).options(
        joinedload(StatusHistory.changed_by_user),
        joinedload(StatusHistory.old_status),
        joinedload(StatusHistory.new_status)
    ).filter(
        StatusHistory.notification_id==notification_id
    ).order_by(StatusHistory.changed_at.desc()).all()

    return {
        "success":True,
        "data":[
            {
                "changed_by":h.changed_by_user.email,
                "old_status":h.old_status.display_name if h.old_status else None,
                "new_status":h.new_status.display_name,
                "changed_at":h.changed_at.isoformat()
            } for h in history
        ]
    }