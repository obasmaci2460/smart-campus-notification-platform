from pydantic import BaseModel, Field
from datetime import datetime
from typing import List

class AdminNoteCreate(BaseModel):
    """
    **Admin Notu Oluşturma Şeması**
    
    Yöneticilerin bir bildirime çözüm süreciyle ilgili not düşerken 
    göndermesi gereken veri yapısıdır.
    """
    note_content: str = Field(
        ..., 
        min_length=1, 
        max_length=500, 
        description="Notun metin içeriği. Boş bırakılamaz ve maksimum 500 karakterdir."
    )

class AdminNoteResponse(BaseModel):
    """
    **Admin Notu Detay Şeması**
    
    API üzerinden bir veya birden fazla not döndürülürken kullanılan 
    ve hassas olmayan verileri içeren yapı.
    """
    id: int
    notification_id: int
    admin_user_id: int
    admin_name: str = Field(..., description="Notu yazan yöneticinin tam adı ve soyadı")
    note_content: str
    created_at: datetime
    updated_at: datetime

    class Config:
        # SQLAlchemy model nesnelerini (ORM) otomatik olarak Pydantic şemasına 
        # dönüştürülmesini sağlar. (Object-Relational Mapping uyumu)
        from_attributes = True

class AdminNotesListResponse(BaseModel):
    """
    **Admin Notları Liste Şeması**
    
    Frontend tarafında (Flutter) sayfalama (pagination) ve toplam sayı 
    bilgisiyle birlikte notları listelemek için kullanılır.
    """
    total: int = Field(..., description="İlgili bildirime ait toplam not sayısı")
    notes: List[AdminNoteResponse] = Field(..., description="Admin notlarının listesi")