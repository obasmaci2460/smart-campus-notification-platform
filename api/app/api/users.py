from fastapi import APIRouter,Depends,HTTPException,status
from sqlalchemy.orm import Session,joinedload
from app.core.database import get_db
from app.models.user import User
from app.schemas.user import (
    UserProfileResponse,
    UserProfileUpdate,
    UserPasswordUpdate,
    NotificationPreferencesResponse,
    NotificationPreferencesUpdate
)
from app.utils.security import get_current_user,verify_password,hash_password

router=APIRouter(prefix="/users",tags=["Users"])

@router.get("/profile",response_model=dict,status_code=status.HTTP_200_OK)
def get_user_profile(
    current_user:User=Depends(get_current_user),
    db:Session=Depends(get_db)):
    
    """Kullanıcı profil bilgilerini görüntüle"""

    user=db.query(User).options(
        joinedload(User.department),
        joinedload(User.notification_preference)
    ).filter(User.id==current_user.id).first()

    response_data=UserProfileResponse(
        id=user.id,
        email=user.email,
        first_name=user.first_name,
        last_name=user.last_name,
        phone=user.phone,
        department_id=user.department_id,
        department_name=user.department.name,
        role=user.role,
        created_at=user.created_at
    ).model_dump()
    
    response_data['is_super_admin'] = user.is_super_admin

    return {
        "success":True,
        "data":response_data,
    }

@router.patch("/profile",response_model=dict,
status_code=status.HTTP_200_OK)
def update_user_profile(
    profile_update:UserProfileUpdate,
    current_user:User=Depends(get_current_user),
    db:Session=Depends(get_db)
):
    "Kullanıcı profil bilgilerini güncelle.Yalnızca gönderilen alanlar güncellenir. Eğer hiçbir alan gönderilmezse 400 hatası döner."

    if not any([
        profile_update.first_name,
        profile_update.last_name,
        profile_update.phone,
        profile_update.department_id
    ]):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "code":"NO_FIELDS_TO_UPDATE",
                "message":"Güncellenecek en az bir alan belirtmelisiniz"
            }
        )

    if profile_update.first_name:
        current_user.first_name=profile_update.first_name
    if profile_update.last_name:
        current_user.last_name=profile_update.last_name
    if profile_update.phone is not None:
        current_user.phone=profile_update.phone
    if profile_update.department_id:
        current_user.department_id=profile_update.department_id

    db.commit()
    db.refresh(current_user)

    user=db.query(User).options(
        joinedload(User.department)
        ).filter(User.id==current_user.id).first()

    response_data=UserProfileResponse(
        id=user.id,
        email=user.email,
        first_name=user.first_name,
        last_name=user.last_name,
        phone=user.phone,
        department_id=user.department_id,
        department_name=user.department.name,
        role=user.role,
        created_at=user.created_at
    ).model_dump()
    
    return {
        "success":True,
        "data":response_data,
        "message":"Profil güncellendi"
    }

@router.patch("/password",response_model=dict,status_code=status.HTTP_200_OK)
def update_user_password(
    password_update:UserPasswordUpdate,
    current_user:User=Depends(get_current_user),
    db:Session=Depends(get_db)
):
    """Kullanıcı şifresini değiştir.Kullanıcının yeni şifre belirleyebilmesi için mevcut şifresini doğrulaması zorunludur. Yeni şifre, utils.security içindeki hashing mekanizmasıyla güvenli hale getirilir."""

    if not verify_password(password_update.current_password,
    current_user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "code":"INVALID_PASSWORD",
                "message":"Mevcut şifre hatalı"
            }
        )

    current_user.password_hash=hash_password(password_update.new_password)     
    
    db.commit()

    return {
        "success":True,
        "message":"Şifre başarıyla değiştirildi"
    }

@router.get("/me/notification-preferences", response_model=dict, status_code=status.HTTP_200_OK)
def get_notification_preferences(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Kullanıcının bildirim tercihlerini getir.Kullanıcının hangi kampüs olayları için bildirim alacağını belirleyen tercihleri döndürür."""
    
    user = db.query(User).options(
        joinedload(User.notification_preference)
    ).filter(User.id == current_user.id).first()
    
    if not user.notification_preference:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Bildirim tercihleri bulunamadı"
        )
    
    pref = user.notification_preference
    
    response_data = NotificationPreferencesResponse(
        notify_security=pref.notify_security,
        notify_maintenance=pref.notify_maintenance,
        notify_cleaning=pref.notify_cleaning,
        notify_infrastructure=pref.notify_infrastructure,
        notify_other=pref.notify_other
    ).model_dump()
    
    return {
        "success": True,
        "data": response_data
    }

@router.patch("/me/notification-preferences", response_model=dict, status_code=status.HTTP_200_OK)
def update_notification_preferences(
    preferences: NotificationPreferencesUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Kullanıcının bildirim tercihlerini güncelle."""
    
    # Dinamik güncelleme: Şema üzerinden gelen tüm alanlar otomatik olarak modele aktarılır.
    
    user = db.query(User).options(
        joinedload(User.notification_preference)
    ).filter(User.id == current_user.id).first()
    
    if not user.notification_preference:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Bildirim tercihleri bulunamadı"
        )
    
    
    pref = user.notification_preference
    
    update_data = preferences.model_dump(exclude_unset=True)
    
    for field, value in update_data.items():
        setattr(pref, field, value)
    
    db.commit()
    db.refresh(pref)
    
    response_data = NotificationPreferencesResponse(
        notify_security=pref.notify_security,
        notify_maintenance=pref.notify_maintenance,
        notify_cleaning=pref.notify_cleaning,
        notify_infrastructure=pref.notify_infrastructure,
        notify_other=pref.notify_other
    ).model_dump()
    
    return {
        "success": True,
        "message": "Bildirim tercihleri güncellendi",
        "data": response_data
    }
