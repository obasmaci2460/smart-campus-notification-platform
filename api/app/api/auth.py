from fastapi import APIRouter , Depends, HTTPException, status,Body,Request  
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.user import User
from app.schemas.auth import UserRegister,TokenResponse,UserLogin,TokenRefresh,AuthSuccessResponse,UserProfileResponse
from app.utils.security import hash_password,get_current_user , create_access_token , verify_password,create_refresh_token,verify_token
from sqlalchemy import text
from jose import JWTError
from app.models.refresh_token import RefreshToken
from datetime import datetime,timedelta
import hashlib
from app.models.failed_login_attempt import FailedLoginAttempt
from sqlalchemy import func

router=APIRouter(prefix="/auth",tags=
["Authentication"])

@router.post("/register",response_model=dict,status_code=status.HTTP_201_CREATED)
def register(user_data:UserRegister,db:Session=Depends(get_db)):
    
    """
    Yeni kullanıcı kaydı oluşturur ve oturum açma token'larını döner.

    - **Email Kontrolü**: Aynı email ile ikinci bir kayıt yapılamaz (422 döner).
    - **Güvenlik**: Kullanıcı şifresi hashlenerek saklanır.
    - **Departman Bağlantısı**: Kullanıcı bir departman ID'si ile ilişkilendirilir.
    - **Başarılı Kayıt**: Kullanıcıya hem Access hem Refresh token anında teslim edilir.
    """
    
    existing_user=db.query(User).filter(User.email==user_data.email).first()
    
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail={
                "code":"EMAIL_ALREADY_EXISTS",
                "message":"Bu e-posta adresi zaten kullanılıyor."
            }
        )

    hashed_pwd=hash_password(user_data.password)

    insert_sql=text("""
        INSERT INTO users
        (email,password_hash,first_name,last_name,department_id,phone,role,is_super_admin,is_active)
        VALUES(:email,:password_hash,:first_name,:last_name,:department_id,:phone,'user',0,1)    
    """)

    db.execute(insert_sql,{
        'email':user_data.email,
        'password_hash':hashed_pwd,
        'first_name':user_data.first_name,
        'last_name':user_data.last_name,
        'department_id':user_data.department_id,
        'phone':user_data.phone
    })

    db.commit()

    new_user=db.query(User).filter(User.email==user_data.email).first()
    
    access_token=create_access_token(
        data={
            "sub":new_user.id,
            "email":new_user.email,
            "role":new_user.role
        }
    )

    refresh_token=create_refresh_token(new_user.id)

    response_data=AuthSuccessResponse(
        user={
            "id":new_user.id,
            "email":new_user.email,
            "first_name":new_user.first_name,
            "last_name":new_user.last_name,
            "role":new_user.role,
            "is_super_admin":new_user.is_super_admin
        },
        tokens=TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=86400
        )
    )

    return {
        "success":True,
        "data":response_data.model_dump(),
        "message":"Kayıt başarılı"
    }


@router.post('/login',response_model=dict,status_code=status.HTTP_200_OK)
def login(
    credentials:UserLogin,
    request:Request,
    db:Session=Depends(get_db)
    ):

    """
    Kullanıcı Girişi
        REQUEST:
            -email:Kayıtlı email adresi
            -password:Kullanıcı şifresi
            -platform:IOS veya ANDROID
            -fcm_token:Firebase Cloude Messaging Token
        RESPONSE:
            -user:Kullanıcı bilgileri
            -tokens:JWT access ve refresh token'lar
        HATALAR:
            -401:Email veya şifre hatalı
            -403:Hesap pasif durumda
            -200:Login Başarılı
            -422:Validation Hatası (Email formatı yanlış.)    
            
    """

    user=db.query(User).filter(
        User.email==credentials.email.lower()
    ).first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={
                "code":"INVALID_CREDENTIALS",
                "message":"Email veya şifre hatalı"
            }
        )

    lock_status=check_account_lock(db,credentials.email.strip().lower())

    if lock_status['is_locked']:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail={
                "code":"ACCOUNT_LOCKED",
                "message":f"Hesabınız {lock_status['retry_after']} saniye süreyle kilitlendi. {lock_status['attempt_count']} başarısız deneme yapıldı.",
                "details":{
                   "locked_until":lock_status["locked_until"].isoformat(),
                   "retry_after":lock_status["retry_after"] 
                }
            }
        )

    if not verify_password(credentials.password,user.password_hash):
        record_failed_attempt(db,
            credentials.email.strip().lower(),
            request.client.host
        )

        remaining=get_remaining_attempts(db,
        credentials.email.strip().lower())    

        if remaining==0:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail={
                    "code":"ACCOUNT_LOCKED",
                    "message":"Hesabınız 5 dakika süreyle kilitlendi",
                    "details":{
                        "locked_until":(datetime.now()+timedelta(minutes=5)).isoformat(),
                        "retry_after":300
                    }
                },
            )
        
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={
                "code":"INVALID_CREDENTIALS",
                "message":f"E-posta veya şifre hatalı . {remaining} deneme hakkınız kaldı"
            }
        )

    clear_failed_attempts(db,credentials.email.strip().lower())

    if not user.is_active:
        raise HTTPException(
           status_code=status.HTTP_403_FORBIDDEN,
           detail={
               "code":"ACCOUNT_INACTIVE",
               "message":"Hesabınız pasif durumda"
           }
    )       

    access_token=create_access_token(
        data={
            "sub":user.id,
            "email":user.email,
            "role":user.role
        }
    )

    refresh_token=create_refresh_token(user.id)

    token_hash=hashlib.sha256(refresh_token.encode()).hexdigest()

    new_rt=RefreshToken(
         user_id=user.id,
         token_hash=token_hash,
         expires_at=datetime.now()+timedelta(days=30)
    )
    
    db.add(new_rt)
    db.commit()

    response_data=AuthSuccessResponse(
        user={
            "id":user.id,
            "email":user.email,
            "first_name":user.first_name,
            "last_name":user.last_name,
            "role":user.role,
            "is_super_admin":user.is_super_admin
        },
        tokens=TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=86400
        )
    )

    return {
        "success":True,
        "data": response_data.model_dump(),
        "message":"Giriş başarılı"
        }


@router.post("/refresh",response_model=dict,status_code=status.HTTP_200_OK)
def refresh_access_token(token_data:TokenRefresh,
db:Session=Depends(get_db)):
    
    """
    Access Token Yenileme

    REQUEST:
    -refresh_token:Geçerli refresh token

    RESPONSE:
    -access_token:Yeni accces token
    -refresh_token:Yeni refresh token(opsiyonel-token rotasyonu)

    HATALAR:
    -401:Token geçersiz veya expired
    -404:Kullanıcı bulunamadı
    """

    try:
        payload=verify_token(token_data.refresh_token)
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={
                "code":"INVALID_TOKEN",
                "message":"Token geçersiz veya süresi dolmuş"
            }
        ) 

    token_type=payload.get("type")
    if token_type!="refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={
                "code":"INVALID_TOKEN_TYPE",
                "message":"Bu bir refresh token değil"
            }
        )

    user_id=payload.get("sub")

    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={
                "code":"INVALID_TOKEN",
                "message":"Token geçersiz"
            }
        )  

    user_id=int(user_id) 
    
    user=db.query(User).filter(User.id==user_id).first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code":"USER_NOT_FOUND",
                "message":"Kullanıcı bulunamadı"
            }
        )

    token_hash=hashlib.sha256(token_data.refresh_token.encode()).hexdigest()

    rt=db.query(RefreshToken).filter(
        RefreshToken.token_hash==token_hash,
        RefreshToken.user_id==user.id,
        ~RefreshToken.is_revoked
    ).first()

    if not rt:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={
                "code":"INVALID_REFRESH_TOKEN",
                "message":"Geçersiz veya iptal edilmiş refresh token"
            }
        )

    rt.is_revoked=True
    rt.revoked_at=datetime.now()
    db.commit()

    new_access_token=create_access_token(
     data={
         "sub":user.id,
         "email":user.email,
         "role":user.role
     }
    )

    new_refresh_token=create_refresh_token(user.id)

    new_token_hash=hashlib.sha256(new_refresh_token.encode()).hexdigest()

    new_rt=RefreshToken(
        user_id=user.id,
        token_hash=new_token_hash,
        expires_at=datetime.now()+timedelta(days=30)
    )

    db.add(new_rt)
    db.commit()

    response_data=TokenResponse(
        access_token=new_access_token,
        refresh_token=new_refresh_token,
        token_type="bearer",
        expires_in=86400
    )

    return {
        "success":True,
        "data":response_data.model_dump(),
        "message":"Token yenilendi."
    }

@router.get("/@me",response_model=dict,status_code=status.HTTP_200_OK)
def get_current_user_info(
    current_user:User=Depends(get_current_user)
):
    
    """
    Mevcut kullanıcı bilgilerini al

    HEADERS:
    -Authorization : Bearer<access_token>

    RESPONSE:
    -user:Kullanıcı bilgileri

    HATALAR:
    -401:Token geçersiz.
    -403:Hesap pasif
    -404:Kullanıcı bulunamadı.

    """

    user_data=UserProfileResponse.model_validate(current_user) 

    return{
        "success":True,
        "data":{
            "user":user_data.model_dump()
        },
        "message":"Kullanıcı bilgileri"
    }


@router.post("/logout",response_model=dict,status_code=status.HTTP_200_OK)
def logout(refresh_token:str=Body(...,embed=True),current_user:User=Depends(get_current_user),db:Session=Depends(get_db)):

    """
    Kullanıcı çıkışı (İleri seviye -Refresh token revoke)

    HEADERS:
    - Authorization : Bearer <access token>

    REQUEST BODY:
    - refresh_token:Kullanıcının refresh token'ı 

    RESPONSE
    -success:true
    -message:Çıkış mesajı

    Notlar:
    -Refresh token database'de revoke edilir.
    -Acces token hala 24 saat geçerli.

    Hatalar:
    -401:Token geçersiz
    -403:Hesap pasif 

    """

    token_hash=hashlib.sha256(refresh_token.encode()).hexdigest()

    rt=db.query(RefreshToken).filter(
        RefreshToken.token_hash==token_hash,
        RefreshToken.user_id==current_user.id,
        ~RefreshToken.is_revoked 
    ).first()

    if rt:
        rt.is_revoked=True
        rt.revoked_at=datetime.now()
        db.commit()

    return {
        "success":True,
        "data":{
            "user_id":current_user.id,
            "email":current_user.email
        },
        "message":f"{current_user.first_name}{current_user.last_name}, başarıyla çıkış yaptınız. Refresh token iptal edildi." 
    }    

def check_account_lock(db:Session,email:str)->dict:
    """
    Hesap kilitli mi kontrol 

    Returns:
        {
            "is_locked":bool,
            "locked_until":datetime or None,
            "retry_after":int (seconds) or None,
            "attempt_count" : int
        }
    """    
    five_minutes_ago = datetime.now() - timedelta(minutes=5)
    attempt_count=db.query(FailedLoginAttempt).filter(
        FailedLoginAttempt.email==email,
        FailedLoginAttempt.attempted_at>=five_minutes_ago
    ).count()
    max_locked=db.query(
        func.max(FailedLoginAttempt.locked_until)
    ).filter(
        FailedLoginAttempt.email==email
    ).scalar()
    if max_locked and datetime.now() < max_locked:
        retry_after = int((max_locked - datetime.now()).total_seconds())
        return {
            "is_locked": True,
            "locked_until": max_locked,
            "retry_after": retry_after,
            "attempt_count":attempt_count
        }
    elif max_locked:
        clear_failed_attempts(db, email)
        return {"is_locked": False, "attempt_count": 0}
    return {
        "is_locked": False,
        "attempt_count": attempt_count or 0
    }

def record_failed_attempt(db:Session,email:str,ip_address:str):
    """Başarısız giriş denemesini kaydet"""

    five_minutes_ago=datetime.now()-timedelta(minutes=5)

    attempt_count=db.execute(text("""
    
    SELECT COUNT(*) FROM failed_login_attempts
    WHERE email= :email AND attempted_at >= :five_minutes_ago
    """),{
        "email":email,
        "five_minutes_ago":five_minutes_ago
    }).scalar()

    if attempt_count>=4:
        locked_until=datetime.now()+timedelta(minutes=5)

        new_attempt=FailedLoginAttempt(
            email=email,
            ip_address=ip_address,
            locked_until=locked_until
        )
    else:
        new_attempt=FailedLoginAttempt(
            email=email,
            ip_address=ip_address
        )    
    db.add(new_attempt)
    db.commit()

def get_remaining_attempts(db:Session,email:str)->int:
    """Kalan deneme hakkını döndür (0-5)"""

    five_minutes_ago=datetime.now()-timedelta(minutes=5)

    attempt_count=db.query(FailedLoginAttempt).filter(
        FailedLoginAttempt.email==email,
        FailedLoginAttempt.attempted_at >= five_minutes_ago
    ).count()

    return max(0,5-(attempt_count or 0))

def clear_failed_attempts(db:Session,email:str):
    """Başarılı giiriş sonrası eski kayıtları temizle"""

    db.query(FailedLoginAttempt).filter(
        FailedLoginAttempt.email==email
    ).delete()

    db.commit()        