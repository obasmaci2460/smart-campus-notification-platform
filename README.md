# 🎓 Smart Campus Notification Platform (Akıllı Kampüs Bildirim Platformu)

<details>
<summary>🇹🇷 Türkçe Başlık / Turkish Title</summary>

# 🎓 Akıllı Kampüs Bildirim Platformu (Smart Campus Notification System)

</details>

![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?logo=flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi&logoColor=white)
![MSSQL](https://img.shields.io/badge/Database-MSSQL-CC2927?logo=microsoft-sql-server&logoColor=white)
![Version](https://img.shields.io/badge/Version-1.0.0-success)

A **Full-Stack** crisis and process management platform developed for real-time reporting of security incidents, technical failures, and other issues occurring within university campuses, their visualization on a map, and systematic tracking by administrators.

The project was developed in accordance with enterprise software standards, with strict adherence to a comprehensive **MVP_SPEC** (Minimum Viable Product Specification) contract containing strict business rules and end-to-end architectural requirements.

<details>
<summary>🇹🇷 Türkçe Açıklama</summary>

Üniversite kampüsleri içerisinde meydana gelen güvenlik olayları, teknik arızalar ve diğer sorunların gerçek zamanlı raporlanması, haritada görselleştirilmesi ve yöneticiler tarafından sistematik olarak takip edilmesi için geliştirilmiş **Full-Stack** bir kriz ve süreç yönetim platformudur.

Proje, katı iş kuralları ve uçtan uca mimari gereksinimleri barındıran kapsamlı bir **MVP_SPEC** (Minimum Viable Product Specification) sözleşmesine tam sadık kalınarak, kurumsal yazılım standartlarında geliştirilmiştir.

</details>

---

## 📜 MVP Specifications and Business Rules (Full Document)

The original MVP Contract containing all details from acceptance criteria and limits to security architecture, which forms the foundation of the project, is provided below.

<details>
<summary>🇹🇷 Türkçe Başlık</summary>

## 📜 MVP Spesifikasyonları ve İş Kuralları (Tam Doküman)

Projenin temelini oluşturan, kabul kriterlerinden (Acceptance Criteria) limitlere ve güvenlik mimarisine kadar tüm detayların yer aldığı orijinal MVP Sözleşmesi aşağıda yer almaktadır.

</details>

<details>
<summary><b>📄 Click to Read the Full MVP_SPEC.md File</b></summary>

```markdown
# MVP_SPEC.md
## Akıllı Kampüs Bildirim Platformu - MVP Kapsamı

**Versiyon:** 1.0  
**Tarih:** 2025-01-15  
**Durum:** Onay Bekliyor

---

## 1. PROJE TANIMI

### 1.1 Ürün Adı
**Akıllı Kampüs Bildirim Platformu**

### 1.2 Temel Problem
Kampüs içerisinde meydana gelen güvenlik olayları, teknik arızalar ve diğer sorunların raporlanması ve takibi konusunda etkin bir sistem bulunmamaktadır. Kullanıcılar sorunları bildirmekte zorlanmakta, yöneticiler ise bu bildirimleri organize bir şekilde yönetememektedir.

### 1.3 Çözüm
Mobil uygulama üzerinden kampüs olaylarının raporlanması, haritada görselleştirilmesi ve yöneticiler tarafından sistematik olarak yönetilmesi.

### 1.4 Hedef Kullanıcı
- **Birincil:** Üniversite öğrencileri ve personeli
- **İkincil:** Kampüs yöneticileri ve güvenlik ekipleri

### 1.5 MVP Odağı
Temel iletişim döngüsü ve kritik güvenlik altyapısının oluşturulması.

---

## 2. ZORUNLU ÖZELLİKLER

### 2.1 Ekran Listesi ve Fonksiyonları

#### Ekran 1: Açılış Ekranı (Splash Screen)
**Fonksiyonlar:**
- [x] Uygulama logosu ve adı gösterilir
- [x] Token kontrolü yapılır
- [x] Token varsa Ana Sayfaya yönlendirme
- [x] Token yoksa Giriş Ekranına yönlendirme

#### Ekran 2: Giriş Ekranı (Login)
**Fonksiyonlar:**
- [x] E-posta ve şifre girişi
- [x] "Giriş Yap" butonu
- [x] "Kayıt Ol" linki
- [x] "Şifremi Unuttum" linki
- [x] Hatalı giriş durumunda animasyonlu uyarı gösterimi
- [x] 5 başarısız deneme sonrası 5 dakika hesap kilitleme

#### Ekran 3: Kayıt Ekranı (Register)
**Fonksiyonlar:**
- [x] Ad girişi (zorunlu)
- [x] Soyad girişi (zorunlu)
- [x] E-posta girişi (.edu kontrolü)
- [x] Şifre girişi (güçlü şifre validasyonu)
- [x] Şifre tekrar girişi
- [x] Birim seçimi (dropdown)
- [x] "Kayıt Ol" butonu
- [x] Başarılı kayıt sonrası otomatik giriş

#### Ekran 4: Şifre Sıfırlama (Mock UI)
**Fonksiyonlar:**
- [x] E-posta adresi girişi
- [x] "Sıfırlama Linki Gönder" butonu
- [x] "Link gönderildi" başarı mesajı gösterimi
- [x] Giriş ekranına dönüş linki

#### Ekran 5: Ana Sayfa (Bildirim Akışı)
**Fonksiyonlar:**
- [x] Bildirim listesi gösterimi (kart yapısı)
- [x] Her kartta: İkon, Başlık, Özet, Zaman, Durum rozeti
- [x] Kronolojik sıralama (en yeni üstte)
- [x] Canlı arama (başlık ve açıklama içinde)
- [x] Tür filtresi (çoklu seçim): Güvenlik, Teknik Arıza, Temizlik, Altyapı, Diğer
- [x] Zaman filtresi: Bugün, Bu hafta, Bu ay
- [x] Alt navigasyon: Ana Sayfa, Harita, Profil sekmeleri
- [x] FAB (Floating Action Button): Yeni Bildirim ve SOS butonu
- [x] Kart tıklamayla Detay Ekranına geçiş
- [x] Pull-to-refresh (yenileme)

#### Ekran 6: Harita Ekranı
**Fonksiyonlar:**
- [x] Google Maps entegrasyonu
- [x] Kampüs merkezi başlangıç konumu
- [x] Kullanıcının canlı konum gösterimi
- [x] Bildirim pinlerinin haritada gösterimi
- [x] Pin renkleri bildirim türüne göre özelleştirilmiş
- [x] Pin tıklamayla Bottom Sheet açılması
- [x] Bottom Sheet'te özet bilgi: Başlık, Tür, Durum
- [x] "Detayı Gör" butonu (Detay Ekranına yönlendirme)
- [x] Tür bazlı filtreleme dropdown'ı
- [x] Zoom in/out kontrolleri

#### Ekran 7: Bildirim Detay Ekranı
**Fonksiyonlar:**
- [x] Büyük ikon ve başlık gösterimi
- [x] Renkli durum rozeti (Açık/İnceleniyor/Çözüldü/Spam)
- [x] Gönderen bilgisi (maskelenmiş): "A. Yılmaz - Mühendislik Fakültesi"
- [x] Tarih ve saat bilgisi
- [x] Tam açıklama metni
- [x] Yatay kaydırılabilir fotoğraf galerisi (maksimum 5 fotoğraf)
- [x] Fotoğraflara tıklamayla Lightbox görünümü
- [x] Konum bilgisi: Adres metni + Mini harita önizlemesi
- [x] "Yol Tarifi Al" butonu (Google Maps'te açma)
- [x] "Takip Et / Takipten Çık" butonu (kalp ikonu)
- [x] Admin ise: "Durum Güncelle" butonu
- [x] Admin ise: "Admin Notu Ekle/Düzenle" alanı

#### Ekran 8: Yeni Bildirim Oluşturma (Sihirbaz - 5 Adım)
**Adım 1: Tür Seçimi**
- [x] Grid yapısında 5 tür gösterimi (ikon ve başlık)
- [x] Seçim yapılınca bir sonraki adıma geçiş

**Adım 2: Detaylar**
- [x] Başlık girişi (maksimum 80 karakter)
- [x] Açıklama girişi (maksimum 500 karakter)
- [x] Canlı karakter sayacı
- [x] "İleri" butonu

**Adım 3: Konum**
- [x] Harita gösterimi
- [x] Pin yerleştirme (sürükle-bırak)
- [x] Seçilen konumun Reverse Geocoding ile adres dönüşümü
- [x] Adres onay metni gösterimi
- [x] "İleri" butonu

**Adım 4: Fotoğraf**
- [x] "Kameradan Çek" butonu
- [x] "Galeriden Seç" butonu
- [x] Maksimum 5 fotoğraf seçimi
- [x] Her fotoğraf maksimum 5MB
- [x] Seçilen fotoğrafların önizlemesi
- [x] Fotoğraf silme (X butonu)
- [x] "İleri" butonu (fotoğraf opsiyonel)

**Adım 5: Önizleme ve Gönder**
- [x] Tüm bilgilerin özet gösterimi
- [x] Fotoğrafların küçük önizlemesi
- [x] "Düzenle" butonları (her bölüm için geri dönüş)
- [x] "Gönder" butonu
- [x] Gönderim sırasında loading animasyonu
- [x] Başarılı gönderim sonrası Ana Sayfaya dönüş

#### Ekran 9: SOS / Panik Butonu
**Fonksiyonlar:**
- [x] Ana ekranda kırmızı, titreşen FAB butonu
- [x] Butona basınca onay paneli açılması
- [x] "Acil Durum Gönderilsin mi?" mesajı
- [x] 3-2-1 geri sayım gösterimi
- [x] Geri sayım sırasında "İptal" butonu
- [x] Geri sayım bitince otomatik gönderim
- [x] Kullanıcının anlık konumu ile yüksek öncelikli güvenlik bildirimi oluşturulması
- [x] Tüm adminlere FCM Critical Alert gönderimi
- [x] Bildirim içeriği: "🚨 Acil Durum! [Kullanıcı] yardım istiyor - [Konum]"

#### Ekran 10: Admin Paneli
**Fonksiyonlar:**
- [x] 3 sekme: "Açık Bildirimler", "Tüm Bildirimler", "İstatistikler"
- [x] Açık Bildirimler sekmesi: Sadece Açık ve İnceleniyor durumundaki bildirimler
- [x] Kart üzerinde sağ/sol kaydırma ile hızlı aksiyon
- [x] Sağa kaydırma: "Çözüldü" işaretleme
- [x] Sola kaydırma: "Spam" işaretleme
- [x] "Acil Bildirim Yayınla" butonu (Broadcast)
- [x] Broadcast için başlık ve mesaj girişi
- [x] Broadcast gönderimi sonrası tüm kullanıcılara push notification
- [x] İstatistikler sekmesi:
  - Toplam bildirim sayısı
  - Çözülen bildirim sayısı
  - Açık bildirim sayısı
  - Kategori dağılımı (bar chart)
  - En çok bildirim gelen birimler listesi

#### Ekran 11: Durum Güncelleme (Bottom Sheet)
**Fonksiyonlar:**
- [x] 4 durum seçeneği: Açık, İnceleniyor, Çözüldü, Spam
- [x] Mevcut durum vurgulanmış gösterilir
- [x] Durum seçimi
- [x] "Güncelle" butonu
- [x] Başarılı güncelleme sonrası toast mesajı

#### Ekran 12: Profil Ekranı
**Fonksiyonlar:**
- [x] İsim baş harflerinden oluşan renkli avatar
- [x] Ad Soyad gösterimi
- [x] Birim bilgisi gösterimi
- [x] "Ayarlar" butonu
- [x] "Çıkış Yap" butonu
- [x] Çıkış yapınca token temizleme ve Giriş Ekranına yönlendirme

#### Ekran 13: Ayarlar Ekranı
**Fonksiyonlar:**
- [x] Şifre değiştirme bölümü:
  - Mevcut şifre girişi
  - Yeni şifre girişi (güçlü şifre validasyonu)
  - Yeni şifre tekrar girişi
  - "Şifreyi Güncelle" butonu
- [x] Bildirim tercihleri:
  - Hangi bildirim türlerinden bildirim alınacağı (toggle'lar)
  - Güvenlik
  - Teknik Arıza
  - Temizlik
  - Altyapı
  - Diğer
- [x] "Kullanıcı Yönetimi" butonu (sadece Admin görür)

#### Ekran 14: Kullanıcı Yönetimi (Admin Only)
**Fonksiyonlar:**
- [x] Tüm kullanıcıların listesi
- [x] Her kullanıcı kartında: Avatar, Ad Soyad, Birim, Rol
- [x] Arama çubuğu (ad-soyad bazlı)
- [x] Admin yetkisi ver/al toggle'ı
- [x] Toggle değişikliğinde onay dialogu
- [x] Super Admin yetkisi alınamaz (toggle disabled)

---

## 3. KAPSAM DIŞI ÖZELLİKLER

Aşağıdaki özellikler MVP'nin hızla çıkabilmesi için **Faz 2'ye ertelenmiştir:**

- [x] **Anonim Gönderim:** Güvenlik riski nedeniyle kapalı
- [x] **Yorumlaşma:** Bildirim altında chat sistemi yok
- [x] **Taslak Kaydetme:** Yarım kalan bildirimler kaydedilmez
- [x] **Harita Kümeleme:** Çoklu pin birleşimi (clustering)
- [x] **Gerçek E-posta Gönderimi:** SMTP entegrasyonu (şifre sıfırlama dahil) yok
- [x] **Profil Fotosu Yükleme:** Sadece harf avatarı kullanılır
- [x] **Detaylı Raporlama:** PDF export, Excel dökümü yok
- [x] **Dark Mode:** Tema değiştirme özelliği yok
- [x] **Çoklu Dil Desteği:** Sadece Türkçe
- [x] **Bildirim Geçmişi:** Kullanıcının kendi gönderdiği bildirimleri görme
- [x] **Takip Listesi:** Takip edilen bildirimlerin ayrı listesi
- [x] **Bildirim İstatistikleri:** Kullanıcı bazlı istatistikler

---

## 4. İŞ KURALLARI

### 4.1 Kimlik Doğrulama ve Güvenlik
- **Kural 4.1.1:** Kayıt için e-posta adresi .edu uzantılı olmalıdır
- **Kural 4.1.2:** Şifre minimum 8 karakter, en az 1 büyük harf, 1 küçük harf, 1 rakam ve 1 özel karakter içermelidir
- **Kural 4.1.3:** Kullanıcı 5 kez yanlış şifre girerse hesap 5 dakika kilitlenir
- **Kural 4.1.4:** JWT Access Token yaşam süresi 24 saattir
- **Kural 4.1.5:** JWT Refresh Token yaşam süresi 30 gündür
- **Kural 4.1.6:** Sisteme kayıt olan ilk kullanıcı otomatik olarak Super Admin rolü alır
- **Kural 4.1.7:** Super Admin yetkisi alınamaz ve değiştirilemez

### 4.2 Bildirim Oluşturma
- **Kural 4.2.1:** Bildirim başlığı maksimum 80 karakter olabilir
- **Kural 4.2.2:** Bildirim açıklaması maksimum 500 karakter olabilir
- **Kural 4.2.3:** Bir bildirime maksimum 5 fotoğraf eklenebilir
- **Kural 4.2.4:** Her fotoğraf maksimum 5MB boyutunda olabilir
- **Kural 4.2.5:** İzin verilen fotoğraf formatları: JPG, PNG
- **Kural 4.2.6:** Konum bilgisi zorunludur
- **Kural 4.2.7:** Bildirim türü zorunludur
- **Kural 4.2.8:** Tüm bildirimler kimlikli gönderilir (anonim gönderim kapalıdır)
- **Kural 4.2.9:** Kullanıcı kendi bildirilerini silemez (sadece admin durum değiştirebilir)

### 4.3 Bildirim Durumları
- **Kural 4.3.1:** Yeni oluşturulan her bildirim "Açık" durumuyla başlar
- **Kural 4.3.2:** Durum değişiklikleri sadece adminler tarafından yapılabilir
- **Kural 4.3.3:** Durum geçişleri: Açık → İnceleniyor → Çözüldü veya Spam
- **Kural 4.3.4:** "Çözüldü" veya "Spam" durumuna geçen bildirimler "Açık Bildirimler" listesinde görünmez
- **Kural 4.3.5:** Durum güncellemesi yapıldığında bildirimi takip eden kullanıcılara push notification gider

### 4.4 Takip Sistemi
- **Kural 4.4.1:** Kullanıcı kendi oluşturduğu bildirimi otomatik olarak takip eder
- **Kural 4.4.2:** Kullanıcı istediği bildirimi takip edebilir veya takipten çıkabilir
- **Kural 4.4.3:** Bildirim durum değişikliklerinde sadece takipçilere bildirim gider
- **Kural 4.4.4:** SOS ve Broadcast bildirimleri takip durumundan bağımsız herkese gider

### 4.5 SOS / Acil Durum
- **Kural 4.5.1:** SOS butonu sadece kullanıcı rolü tarafından kullanılabilir
- **Kural 4.5.2:** SOS tetiklendiğinde 3 saniye geri sayım başlar
- **Kural 4.5.3:** Geri sayım sırasında iptal edilebilir
- **Kural 4.5.4:** Geri sayım bittiğinde otomatik olarak "Yüksek Öncelikli" güvenlik bildirimi oluşturulur
- **Kural 4.5.5:** SOS bildirimi oluşturulduğunda tüm adminlere FCM Critical Alert gider
- **Kural 4.5.6:** SOS bildirimi kullanıcının anlık konumu ile oluşturulur
- **Kural 4.5.7:** Bir kullanıcı günde maksimum 3 kez SOS kullanabilir (spam önleme)

### 4.6 Admin Yetkileri
- **Kural 4.6.1:** Admin, tüm bildirimleri görüntüleyebilir ve yönetebilir
- **Kural 4.6.2:** Admin, bildirim durumlarını değiştirebilir
- **Kural 4.6.3:** Admin, bildirimlere not ekleyebilir ve düzenleyebilir
- **Kural 4.6.4:** Admin, Broadcast (acil duyuru) yayınlayabilir
- **Kural 4.6.5:** Admin, diğer kullanıcılara admin yetkisi verebilir veya alabilir
- **Kural 4.6.6:** Admin, Super Admin yetkisini alamaz
- **Kural 4.6.7:** Broadcast bildirimi günde maksimum 5 kez gönderilebilir

### 4.8 Görünürlük ve Gizlilik
- **Kural 4.8.1:** Admin, bildirim gönderenin tam bilgilerini görür (Ad Soyad + Birim + Telefon)
- **Kural 4.8.2:** Kullanıcı, bildirim gönderenin sadece maskelenmiş bilgilerini görür (A. Yılmaz - Mühendislik Fakültesi)
- **Kural 4.8.3:** Profil avatarı, isim baş harflerinden oluşan renkli daire olarak gösterilir

### 4.9 Veri Bütünlüğü
- **Kural 4.9.1:** Konum verisi hem Geography tipi (Latitude, Longitude) hem de adres metni olarak saklanır
- **Kural 4.9.2:** Silinen bildirimler hard delete edilmez, "deleted_at" timestamp'i ile soft delete yapılır
- **Kural 4.9.3:** Fotoğraflar AWS S3'te saklanır, veritabanında sadece URL tutulur

---

## 5. KABUL KRİTERLERİ (ACCEPTANCE CRITERIA)

### 5.1 Kimlik Doğrulama

#### AC 5.1.1: Kullanıcı Kaydı
- Kullanıcı tüm zorunlu alanları doldurduğunda "Kayıt Ol" butonu aktif olur
- E-posta .edu uzantılı değilse hata mesajı gösterilir
- Şifre güçlü şifre kriterlerini sağlamazsa hata mesajı gösterilir
- Başarılı kayıt sonrası kullanıcı otomatik olarak Ana Sayfaya yönlendirilir

#### AC 5.1.2: Kullanıcı Girişi
- Doğru e-posta ve şifre ile giriş yapıldığında Ana Sayfaya yönlendirilir
- Yanlış şifre girildiğinde animasyonlu hata mesajı gösterilir
- 5 yanlış deneme sonrası "Hesap 5 dakika kilitlendi" mesajı gösterilir

#### AC 5.1.3: Token Yönetimi
- Başarılı giriş sonrası Access ve Refresh token'lar cihazda saklanır
- Uygulama her açılışta token kontrolü yapar
- Token geçersizse Giriş Ekranına yönlendirilir

### 5.2 Bildirim Oluşturma

#### AC 5.2.1: Tür Seçimi
- 5 bildirim türü grid yapısında gösterilir
- Bir tür seçildiğinde bir sonraki adıma geçiş yapılır
- Geri butonu ile önceki ekrana dönülebilir

#### AC 5.2.2: Detay Girişi
- Başlık 80 karakteri geçince yazılamaz ve kırmızı sayaç gösterilir
- Açıklama 500 karakteri geçince yazılamaz ve kırmızı sayaç gösterilir
- Başlık ve açıklama boş ise "İleri" butonu disabled olur

#### AC 5.2.3: Konum Seçimi
- Harita yüklendiğinde kampüs merkezi gösterilir
- Pin sürüklenerek konum seçilir
- Seçilen konum Reverse Geocoding ile adres metnine dönüştürülür
- Adres metni ekranda gösterilir

#### AC 5.2.4: Fotoğraf Yükleme
- Maksimum 5 fotoğraf seçilebilir
- 5 fotoğraf seçildikten sonra "Ekle" butonları disabled olur
- 5MB'dan büyük fotoğraf seçildiğinde hata mesajı gösterilir
- Fotoğraf opsiyoneldir, fotoğrafsız devam edilebilir

#### AC 5.2.5: Önizleme ve Gönderim
- Tüm bilgiler özet olarak gösterilir
- "Düzenle" butonlarıyla ilgili adıma geri dönülebilir
- "Gönder" butonuna basıldığında loading animasyonu gösterilir
- Başarılı gönderim sonrası Ana Sayfaya dönülür ve toast mesajı gösterilir

### 5.3 Bildirim Listesi ve Görüntüleme

#### AC 5.3.1: Ana Sayfa Listesi
- Bildirimler kronolojik sırayla (en yeni üstte) gösterilir
- Her kartta ikon, başlık, özet (ilk 100 karakter), zaman ve durum rozeti vardır
- Kart tıklandığında Detay Ekranına geçiş yapılır
- Pull-to-refresh ile liste yenilenir

#### AC 5.3.2: Arama
- Arama çubuğuna yazıldığında canlı arama yapılır
- Başlık ve açıklama içerisinde arama yapılır
- Sonuç bulunamazsa "Sonuç bulunamadı" mesajı gösterilir

#### AC 5.3.3: Filtreleme
- Tür filtresi çoklu seçime izin verir
- Zaman filtresi tek seçimdir
- Filtre uygulandığında liste anında güncellenir
- Filtre temizlendiğinde tüm bildirimler gösterilir

### 5.4 Harita

#### AC 5.4.1: Harita Gösterimi
- Harita yüklendiğinde kampüs merkezi gösterilir
- Kullanıcının mevcut konumu mavi nokta ile gösterilir
- Tüm bildirimler pin olarak gösterilir
- Pin renkleri bildirim türüne göre farklıdır

#### AC 5.4.2: Pin Etkileşimi
- Pin'e tıklandığında Bottom Sheet açılır
- Bottom Sheet'te başlık, tür ve durum bilgisi gösterilir
- "Detayı Gör" butonuna basıldığında Detay Ekranına geçilir

#### AC 5.4.3: Filtreleme
- Dropdown'dan tür seçildiğinde sadece o türdeki pinler gösterilir
- "Tümü" seçildiğinde tüm pinler gösterilir

### 5.5 Bildirim Detayı

#### AC 5.5.1: Bilgi Gösterimi
- Başlık, tür, durum, gönderen (maskelenmiş), tarih ve tam açıklama gösterilir
- Fotoğraflar varsa yatay kaydırılabilir galeri gösterilir
- Fotoğraflara tıklandığında Lightbox görünümü açılır

#### AC 5.5.2: Konum Bilgisi
- Adres metni gösterilir
- Mini harita önizlemesi gösterilir
- "Yol Tarifi Al" butonuna basıldığında Google Maps uygulaması açılır

#### AC 5.5.3: Takip Sistemi
- Kalp ikonu boş ise "Takip Et", dolu ise "Takipten Çık" olarak gösterilir
- Tıklandığında durum tersine çevrilir ve toast mesajı gösterilir
- Kullanıcı kendi bildirilerini varsayılan olarak takip eder

#### AC 5.5.4: Admin İşlemleri
- Admin ise "Durum Güncelle" ve "Admin Notu" bölümleri gösterilir
- Durum güncelleme sonrası toast mesajı gösterilir ve sayfa yenilenir
- Admin notu eklendikten/güncellendikten sonra kaydedilir ve gösterilir

### 5.6 SOS / Panik Butonu

#### AC 5.6.1: Tetikleme
- Kırmızı FAB butonu titreşim animasyonuyla gösterilir
- Butona basıldığında onay paneli açılır
- "Acil Durum Gönderilsin mi?" mesajı gösterilir

#### AC 5.6.2: Geri Sayım
- 3-2-1 geri sayım gösterilir
- Geri sayım sırasında "İptal" butonu aktiftir
- İptal edildiğinde panel kapanır
- Geri sayım bittiğinde otomatik olarak SOS bildirimi gönderilir

#### AC 5.6.3: Bildirim Gönderimi
- Kullanıcının anlık konumu ile "Güvenlik" türünde bildirim oluşturulur
- Tüm adminlere FCM Critical Alert gider
- Başarılı gönderim sonrası onay mesajı gösterilir

### 5.7 Admin Paneli

#### AC 5.7.1: Sekme Yapısı
- 3 sekme gösterilir: Açık Bildirimler, Tüm Bildirimler, İstatistikler
- Açık Bildirimler sekmesinde sadece "Açık" ve "İnceleniyor" durumundaki bildirimler gösterilir
- Tüm Bildirimler sekmesinde tüm bildirimler gösterilir

#### AC 5.7.2: Hızlı Aksiyon
- Kart sağa kaydırıldığında "Çözüldü" işaretlenir
- Kart sola kaydırıldığında "Spam" işaretlenir
- İşlem sonrası toast mesajı gösterilir

#### AC 5.7.3: Broadcast
- "Acil Bildirim Yayınla" butonuna basıldığında form açılır
- Başlık ve mesaj girişi yapılır
- Gönderim sonrası tüm kullanıcılara push notification gider

#### AC 5.7.4: İstatistikler
- Toplam, çözülen ve açık bildirim sayıları gösterilir
- Kategori dağılımı bar chart ile gösterilir
- En çok bildirim gelen 5 birim listelenir

### 5.8 Profil ve Ayarlar

#### AC 5.8.1: Profil Gösterimi
- İsim baş harflerinden oluşan renkli avatar gösterilir
- Ad Soyad ve birim bilgisi gösterilir
- "Ayarlar" ve "Çıkış Yap" butonları gösterilir

#### AC 5.8.2: Şifre Değiştirme
- Mevcut şifre, yeni şifre ve yeni şifre tekrar alanları gösterilir
- Mevcut şifre yanlışsa hata mesajı gösterilir
- Yeni şifre güçlü şifre kriterlerini sağlamazsa hata mesajı gösterilir
- Başarılı güncelleme sonrası başarı mesajı gösterilir

#### AC 5.8.3: Bildirim Tercihleri
- 5 bildirim türü için toggle'lar gösterilir
- Toggle değiştirildiğinde tercihler kaydedilir
- SOS ve Broadcast bildirimleri toggle'lardan bağımsızdır

### 5.9 Kullanıcı Yönetimi (Admin Only)

#### AC 5.9.1: Kullanıcı Listesi
- Tüm kullanıcılar listeyle gösterilir
- Her kullanıcı kartında avatar, ad soyad, birim ve rol gösterilir
- Admin olan kullanıcıların toggle'ı aktiftir

#### AC 5.9.2: Rol Yönetimi
- Toggle değiştirildiğinde onay dialogu açılır
- Onay verildiğinde rol güncellenir ve toast mesajı gösterilir
- Super Admin yetkisi toggle'ı disabled'dır (değiştirilemez)

#### AC 5.9.3: Arama
- Arama çubuğuna yazıldığında canlı arama yapılır
- Ad ve soyad bazında arama yapılır

---

## 6. BAŞARI KRİTERLERİ

### 6.1 Fonksiyonel Başarı
- [x] Kullanıcı başarılı bir şekilde kayıt olabilir ve giriş yapabilir
- [x] Kullanıcı bildirim oluşturabilir ve gönderebilir
- [x] Bildirimler liste ve harita üzerinde görüntülenebilir
- [x] Admin bildirim durumlarını güncelleyebilir
- [x] SOS butonu çalışır ve adminlere bildirim gider
- [x] Push notification sistemi çalışır

### 6.2 Performans Başarısı
- [x] Uygulama açılış süresi < 3 saniye
- [x] Bildirim listesi yükleme süresi < 2 saniye
- [x] Harita yükleme süresi < 3 saniye
- [x] Fotoğraf yükleme süresi < 5 saniye (5MB için)

### 6.3 Kullanılabilirlik Başarısı
- [x] Kullanıcı bildirim oluşturma akışını < 2 dakikada tamamlayabilir
- [x] Navigasyon sezgiseldir ve kullanıcı kaybolmaz
- [x] Hata mesajları anlaşılırdır ve yönlendiricidir

### 6.4 Güvenlik Başarısı
- [x] Tüm API istekleri JWT ile güvenlidir
- [x] Şifreler bcrypt ile hash'lenir
- [x] .edu domain kontrolü çalışır
- [x] Rate limiting uygulanır (5 yanlış şifre = 5 dk kilit)

---

## 7. TEKNIK KISITLAMALAR

### 7.1 Platform
- [x] Mobil uygulama: Flutter (iOS ve Android)
- [x] Minimum iOS versiyonu: 12.0
- [x] Minimum Android versiyonu: 8.0 (API Level 26)

### 7.2 Ağ ve Bağlantı
- [x] İnternet bağlantısı zorunludur
- [x] Offline mod desteklenmez

### 7.3 Cihaz İzinleri
- [x] Konum izni (zorunlu)
- [x] Kamera izni (opsiyonel)
- [x] Galeri izni (opsiyonel)
- [x] Bildirim izni (önerilen)

### 7.4 Veri Sınırlamaları
- [x] Maksimum fotoğraf boyutu: 5MB
- [x] Maksimum fotoğraf sayısı per bildirim: 5
- [x] Maksimum başlık uzunluğu: 80 karakter
- [x] Maksimum açıklama uzunluğu: 500 karakter

---

## 8. RİSKLER VE VARSAYIMLAR

### 8.1 Riskler
- [x] **Risk 8.1.1:** Kullanıcılar .edu e-posta adresi olmayabilir
  - **Azaltma:** İlk aşamada manuel onay sistemi eklenmesi
- [x] **Risk 8.1.2:** Google Maps API maliyeti yüksek olabilir
  - **Azaltma:** Aylık kullanım limiti takibi ve uyarı sistemi
- [x] **Risk 8.1.3:** Push notification'lar ulaşmayabilir
  - **Azaltma:** In-app notification sistemi yedek olarak kullanılır

### 8.2 Varsayımlar
- [x] **Varsayım 8.2.1:** Kullanıcılar akıllı telefon sahibidir
- [x] **Varsayım 8.2.2:** Kampüs içinde yeterli internet bağlantısı vardır
- [x] **Varsayım 8.2.3:** Kullanıcılar Türkçe dilini bilir
- [x] **Varsayım 8.2.4:** Admin sayısı başlangıçta 5-10 kişi ile sınırlıdır

---

## 9. BAĞIMLILIKLAR

### 9.1 Harici Servisler
- [x] Google Maps API (harita ve geocoding)
- [x] Firebase Cloud Messaging (push notification)
- [x] AWS S3 veya Google Cloud Storage (fotoğraf depolama)

### 9.2 Backend Bağımlılıkları
- [x] FastAPI backend hazır olmalıdır
- [x] MSSQL veritabanı kurulu ve yapılandırılmış olmalıdır
- [x] API_SPEC.md dokümante edilmiş ve onaylanmış olmalıdır

---

## 10. ONAY VE İMZALAR

### Doküman Hazırlayan
**İsim:** Ömer Basmacı  
**Rol:** Product Owner / Developer  
**Tarih:** 2026-03-24  

```
</details>

---

## 🏗️ System Architecture and Technical Documentation

A high-performance FastAPI server and an MSSQL database supporting spatial queries run in the background of the application.

<details>
<summary>🇹🇷 Türkçe</summary>

## 🏗️ Sistem Mimarisi ve Teknik Dokümantasyon

Uygulamanın arka planında yüksek performanslı bir FastAPI sunucusu ve coğrafi (spatial) sorguları destekleyen MSSQL veritabanı çalışmaktadır.

</details>

### Entity-Relationship (ER) Diagram
The database is fully normalized. The `failed_login_attempts` table for user auditing, `status_history` for system tracking, and `admin_notes` for administrator communication notes are all designed relationally.

<details>
<summary>🇹🇷 Türkçe</summary>

### Varlık-İlişki (ER) Diyagramı
Veritabanı tamamen normalize edilmiştir. Kullanıcı denetimi için `failed_login_attempts`, sistem takibi için `status_history` ve yöneticilerin iletişim notları için `admin_notes` tabloları ilişkisel olarak tasarlanmıştır.

</details>

<p align="center">
  <img src="docs/ER.png" width="85%" alt="ER Diagram">
</p>

### RESTful API (Swagger Docs)
All client-server communication is provided through OpenAPI standard endpoints, sealed with Pydantic schemas and equipped with JWT token-based security layers.

<details>
<summary>🇹🇷 Türkçe</summary>

### RESTful API (Swagger Docs)
Tüm client-server iletişimi Pydantic şemaları ile mühürlenmiş, JWT token bazlı güvenlik katmanlarıyla donatılmış OpenAPI standartlarındaki endpoint'ler üzerinden sağlanır.

</details>

<details>
<summary><b>Click to View API Endpoint Documentation</b></summary>
<p align="center">
  <img src="docs/DOCS1.png" width="90%">
  <br>
  <img src="docs/DOCS2.png" width="90%">
  <br>
  <img src="docs/DOCS3.png" width="90%">
</p>
</details>

---

## 📱 User Flow and Modules (User Journey)

<details>
<summary>🇹🇷 Türkçe Başlık</summary>

## 📱 Kullanıcı Akışı ve Modüller (User Journey)

</details>

### 📁 1. App Icon
The user's first point of contact with the system. Clean and comprehensible brand identity.

<details>
<summary>🇹🇷 Türkçe</summary>

### 📁 1. Uygulama İkonu
Kullanıcının sisteme ilk temas noktası. Temiz ve anlaşılır marka kimliği.

</details>

<p align="center">
  <img src="docs/I1.jpeg" width="24%">
</p>

### 📁 2. Splash Screen
On application launch, a JWT Token check is performed in the background via `Secure Storage`. If a valid token exists, the user is directed to the main flow; otherwise, they are redirected to the animated Login screen.

<details>
<summary>🇹🇷 Türkçe</summary>

### 📁 2. Splash Screen Açılışı
Uygulama açılışında arka planda `Secure Storage` üzerinden JWT Token kontrolü yapılır. Geçerli token varsa doğrudan ana akışa, yoksa animasyonlu Login ekranına yönlendirilir.

</details>

<p align="center">
  <img src="docs/SP1.jpeg" width="24%"> <img src="docs/SP2.jpeg" width="24%">
</p>

### 📁 3. Login
The heart of the security wall. Email form validations are performed directly on the Flutter UI side (Regex).
* **Brute-Force Protection:** If a user enters the wrong password 5 times, the account is locked for 5 minutes. This state is tracked in real-time in the backend logs (`failed_login_attempts`) along with the IP address.

<details>
<summary>🇹🇷 Türkçe</summary>

### 📁 3. Login
Güvenlik duvarının kalbi. E-posta form validasyonları doğrudan Flutter UI tarafında (Regex) gerçekleştirilir.
* **Brute-Force Koruması:** Kullanıcı 5 kez yanlış şifre girerse hesap 5 dakika kilitlenir. Bu durum backend loglarında (`failed_login_attempts`) IP adresiyle birlikte anlık tutulur.

</details>

<p align="center">
  <img src="docs/LG1.jpeg" width="19%"> <img src="docs/LG2.jpeg" width="19%"> <img src="docs/LG3.jpeg" width="19%"> <img src="docs/LG4.jpeg" width="19%"> <img src="docs/LG5.jpeg" width="19%">
  <br>
  <img src="docs/LG6.jpeg" width="19%"> <img src="docs/LG8.jpeg" width="19%"> <img src="docs/LG9.jpeg" width="19%"> <img src="docs/LG10.jpeg" width="19%"> 
  <br>
  <img src="docs/LG7.png" width="80%"> 
</p>

### 📁 4. Register
The registration module that ensures only authorized individuals can enter the system.
* **.edu Validation:** The email address must have a .edu extension for registration.
* **Password Security:** Password must be a minimum of 8 characters, containing at least 1 uppercase letter, 1 lowercase letter, 1 digit, and 1 special character. The real-time security level (Strong 5/5) is displayed on the UI.

<details>
<summary>🇹🇷 Türkçe</summary>

### 📁 4. Register
Sisteme sadece yetkili kişilerin girmesini sağlayan kayıt modülü.
* **.edu Doğrulaması:** Kayıt için e-posta adresi .edu uzantılı olmalıdır.
* **Şifre Güvenliği:** Şifre minimum 8 karakter, en az 1 büyük harf, 1 küçük harf, 1 rakam ve 1 özel karakter içermelidir. Anlık güvenlik seviyesi (Güçlü 5/5) UI üzerinde gösterilir.

</details>

<p align="center">
  <img src="docs/RG1.jpeg" width="19%"> <img src="docs/RG2.jpeg" width="19%"> <img src="docs/RG3.jpeg" width="19%"> <img src="docs/RG4.jpeg" width="19%"> <img src="docs/RG5.jpeg" width="19%">
</p>

### 📁 5. Notification and SOS
The platform's main data flow and crisis intervention engine.
* **Filtering:** Real-time filtering can be applied by category and time.
* **Emergency Algorithm:** When the SOS button is pressed, a 3-2-1 countdown begins. When the countdown ends, a "High Priority" security notification is created with the user's current location.
* **Anti-Abuse Protection (Rate Limit):** A user can use SOS a maximum of 3 times per day; otherwise the system returns a 429 error and a red warning appears in the UI.

<details>
<summary>🇹🇷 Türkçe</summary>

### 📁 5. Notification and SOS
Platformun ana veri akışı ve kriz anı müdahale motoru. 
* **Filtreleme:** Kategorilere ve zamana göre anlık filtreleme yapılabilir.
* **Acil Durum Algoritması:** SOS butonuna basıldığında 3-2-1 geri sayım başlar. Geri sayım bitince kullanıcının anlık konumu ile "Yüksek Öncelikli" güvenlik bildirimi oluşturulur.
* **Suistimal Koruması (Rate Limit):** Bir kullanıcı günde maksimum 3 kez SOS kullanabilir, aksi halde sistem 429 hatası döndürür ve UI'da kırmızı uyarı çıkar.

</details>

<p align="center">
  <img src="docs/NS1.jpeg" width="19%"> <img src="docs/NS2.jpeg" width="19%"> <img src="docs/NS3.jpeg" width="19%"> <img src="docs/NS4.jpeg" width="19%"> <img src="docs/NS5.jpeg" width="19%">
  <br>
  <img src="docs/NS6.jpeg" width="19%"> <img src="docs/NS7.jpeg" width="19%"> <img src="docs/NS8.jpeg" width="19%"> <img src="docs/NS9.jpeg" width="19%"> <img src="docs/NS10.jpeg" width="19%">
</p>

### 📁 6. Maps and Going Details
A bird's-eye view of the entire campus through Google Maps integration.
* **Spatial SQL:** Thanks to the MSSQL `geography::STDistance` function, markers near the user's location are optimally retrieved from the database.
* Tapping a pin opens a Bottom Sheet, providing a smooth transition to details.

<details>
<summary>🇹🇷 Türkçe</summary>

### 📁 6. Maps and Going Details
Google Maps entegrasyonu ile kampüs genelinin kuş bakışı incelenmesi.
* **Mekansal SQL:** MSSQL `geography::STDistance` fonksiyonu sayesinde kullanıcının bulunduğu konuma yakın marker'lar veritabanından optimize edilerek çekilir.
* Pin'e tıklamayla Bottom Sheet açılır ve detaylara pürüzsüz geçiş sağlanır.

</details>

<p align="center">
  <img src="docs/MD1.jpeg" width="24%"> <img src="docs/MD2.jpeg" width="24%"> <img src="docs/MD3.jpeg" width="24%"> <img src="docs/MD4.jpeg" width="24%">
  <br>
  <img src="docs/MD5.jpeg" width="24%"> <img src="docs/MD6.jpeg" width="24%"> <img src="docs/MD7.jpeg" width="24%"> <img src="docs/MD8.jpeg" width="24%">
</p>

### 📁 7. Create Notification And Going Details
A multi-data (text + coordinate + media) processing module with Form-Data structure.
* **Data Limits:** Notification title can be a maximum of 80, description 500 characters. A maximum of 5 photos, each up to 5MB, can be attached to a notification.
* Location data is stored both as Geography type (Latitude, Longitude) and as address text (Reverse Geocoding).

<details>
<summary>🇹🇷 Türkçe</summary>

### 📁 7. Create Notification And Going Details
Form-Data yapısı ile çoklu veri (metin + koordinat + medya) işleme modülü.
* **Veri Sınırları:** Bildirim başlığı maksimum 80, açıklaması 500 karakter olabilir. Bir bildirime maksimum 5 adet 5MB boyutunda fotoğraf eklenebilir.
* Konum verisi hem Geography tipi (Latitude, Longitude) hem de adres metni (Reverse Geocoding) olarak saklanır.

</details>

<p align="center">
  <img src="docs/CD1.jpeg" width="30%"> <img src="docs/CD2.jpeg" width="30%"> <img src="docs/CD3.jpeg" width="30%">
  <br>
  <img src="docs/CD4.jpeg" width="30%"> <img src="docs/CD5.jpeg" width="30%"> <img src="docs/CD6.jpeg" width="30%">
</p>

### 📁 8. Notifications Details and Functions
The detail page where social interaction (Follow) and Administrator (Admin) workflows are executed.
* **CRUD and Status:** Only the notification owner can update the description. Status changes (Open → Under Review → Resolved) can only be made by admins.
* **Admin Notes:** Administrators can intervene in notifications in real-time and leave permanent notes (`admin_notes`).
* **Soft Delete:** Data is not permanently deleted; database integrity is preserved.

<details>
<summary>🇹🇷 Türkçe</summary>

### 📁 8. Notifications Details and Functions
Sosyal etkileşim (Takip Et) ve Yönetici (Admin) iş akışlarının yürütüldüğü detay sayfası.
* **CRUD ve Durum:** Yalnızca bildirim sahibi açıklamayı güncelleyebilir. Durum değişiklikleri (Açık → İnceleniyor → Çözüldü) sadece adminler tarafından yapılabilir.
* **Admin Notları:** Yöneticiler bildirimlere anlık müdahale edip kalıcı notlar (`admin_notes`) bırakabilir.
* **Soft Delete:** Veriler kalıcı silinmez, veritabanı bütünlüğü korunur.

</details>

<p align="center">
  <img src="docs/NDF1.jpeg" width="19%"> <img src="docs/NDF2.jpeg" width="19%"> <img src="docs/NDF3.jpeg" width="19%"> <img src="docs/NDF4.jpeg" width="19%"> <img src="docs/NDF5.jpeg" width="19%">
  <br>
  <img src="docs/NDF6.jpeg" width="19%"> <img src="docs/NDF7.jpeg" width="19%"> <img src="docs/NDF8.jpeg" width="19%"> <img src="docs/NDF9.jpeg" width="19%"> <img src="docs/NDF10.jpeg" width="19%">
  <br>
  <img src="docs/NDF11.jpeg" width="24%"> <img src="docs/NDF12.jpeg" width="24%"> <img src="docs/NDF13.jpeg" width="24%"> <img src="docs/NDF14.jpeg" width="24%">
</p>

### 📁 9. Settings
The final module where Role-Based Access Control (RBAC) authorizations and user preferences are managed.
* **Admin Panel:** Super Admin and Admin roles view statistical `COUNT` summaries of all notifications in the system through a dedicated Dashboard.
* Password change, notification preferences, and secure logout (JWT token destruction) features are provided.

<details>
<summary>🇹🇷 Türkçe</summary>

### 📁 9. Settings
Role-Based Access Control (RBAC) yetkilendirmeleri ve kullanıcı tercihlerinin yönetildiği final modülü.
* **Admin Panel:** Super Admin ve Admin rolleri, sistemdeki tüm bildirimlerin istatistiksel `COUNT` özetlerini özel bir Dashboard üzerinden görüntüler.
* Bildirim tercihleri, şifre değişikliği ve güvenli oturum kapatma (JWT token imhası) özellikleri sunulur.

</details>

<p align="center">
  <img src="docs/S1.jpeg" width="30%"> <img src="docs/S2.jpeg" width="30%"> <img src="docs/S3.jpeg" width="30%">
  <br>
  <img src="docs/S4.jpeg" width="30%"> <img src="docs/S5.jpeg" width="30%"> <img src="docs/S6.jpeg" width="30%">
  <br>
  <img src="docs/S7.jpeg" width="30%"> <img src="docs/S8.jpeg" width="30%"> <img src="docs/S9.jpeg" width="30%">
</p>

---

## 🛠️ How to Run / Nasıl Çalıştırılır?

This project is a monorepo consisting of **Backend (FastAPI)**, **Frontend (Flutter)**, and **Database (MSSQL)** folders. Follow the technical steps below to run the system in your local environment.

<details>
<summary>🇹🇷 Türkçe</summary>

Bu proje **Backend (FastAPI)**, **Frontend (Flutter)** ve **Database (MSSQL)** klasörlerinden oluşan bir monorepo yapısındadır. Sistemi yerel ortamınızda ayağa kaldırmak için aşağıdaki teknik adımları izleyin.

</details>

---

### 1. Database Setup (MSSQL) 🗄️

The database layer uses **Spatial Data Types** for location-based data.

* **Schema Creation:** Run the SQL scripts under `db/tables/` in order to build the relational table structure.
* **Logical Structures:** Apply the scripts under `db/sp/` (Stored Procedures), `db/triggers/`, and `db/indexes/` to activate business logic and performance optimizations on the database engine.
* **Seed Data:** Import the constants required for the application to function (Units, Categories, Statuses) using the SQL files under `db/seeds/` to ensure table structures are operational.
* **Test Data Generation (Faker):** To generate 100+ random notifications for the development environment:
    ```bash
    cd db/seeds/faker_seed_data
    # Activate virtual environment and configure .env file
    python learn_faker_library.py
    ```

<details>
<summary>🇹🇷 Türkçe</summary>

### 1. Database Setup (MSSQL) 🗄️

Veritabanı katmanı, konumsal veriler için **Spatial Data Types** kullanmaktadır.

* **Şema Oluşturma:** `db/tables/` altındaki SQL scriptlerini sırayla çalıştırarak ilişkisel tablo yapısını kurun.
* **Mantıksal Yapılar:** `db/sp/` (Stored Procedures), `db/triggers/` ve `db/indexes/` altındaki scriptleri uygulayarak veritabanı motoru üzerindeki iş mantığını ve performans optimizasyonlarını aktif hale getirin.
* **Temel Veriler:** Uygulamanın çalışması için gerekli olan sabitleri (Birimler, Kategoriler, Durumlar) `db/seeds/` altındaki SQL dosyaları ile içeri aktararak tablo yapılarının işlevselliğini sağlayın.
* **Test Verisi Üretimi (Faker):** Geliştirme ortamı için 100+ rastgele bildirim üretmek isterseniz:
    ```bash
    cd db/seeds/faker_seed_data
    # Sanal ortamı aktif edin ve .env dosyasını yapılandırın
    python learn_faker_library.py
    ```

</details>

---

### 2. Backend Setup (FastAPI) 🐍

The backend is sealed with Pydantic models and protected with a JWT-based security layer.

* **Environment Preparation:** Navigate to the `api/` directory, create a `venv`, and install packages from `requirements.txt`.
* **Configuration:** Create an `api/.env` file and define the `DATABASE_URL` (MSSQL Connection String) and `JWT_SECRET` variables.
* **Starting the Server:**
    ```bash
    uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    ```
* **External Access (Ngrok):** Use **Ngrok** to forward your local port 8000 to a global URL so that your mobile device can access the local server.

<details>
<summary>🇹🇷 Türkçe</summary>

### 2. Backend Setup (FastAPI) 🐍

Backend, Pydantic modelleri ile mühürlenmiş ve JWT tabanlı güvenlik katmanıyla korunmaktadır.

* **Ortam Hazırlığı:** `api/` dizinine gidin, bir `venv` oluşturun ve `requirements.txt` paketlerini yükleyin.
* **Konfigürasyon:** `api/.env` dosyasını oluşturun; `DATABASE_URL` (MSSQL Connection String) ve `JWT_SECRET` değişkenlerini tanımlayın.
* **Sunucuyu Başlatma:**
    ```bash
    uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    ```
* **Dış Dünyaya Erişim (Ngrok):** Mobil cihazınızın yerel sunucuya erişebilmesi için **Ngrok** kullanarak yerel 8000 portunu global bir URL'ye yönlendirin.

</details>

---

### 3. Frontend Setup (Flutter) 📱

The mobile application requires Google Maps integration and hardware permissions (Location, Camera).

* **Dependencies:** Download the required packages with the `flutter pub get` command in the `campus_app/` directory.
* **Map Integration:** Add your own **Google Maps API Key** to the `AndroidManifest.xml` (Android) and `AppDelegate.swift` (iOS) files.
* **API Connection:** Update the API URL in the application with your own **Ngrok** address to enable communication through the tunnel.
* **Running:** With your device connected, enter the following command in the terminal:
    ```bash
    flutter run
    ```

<details>
<summary>🇹🇷 Türkçe</summary>

### 3. Frontend Setup (Flutter) 📱

Mobil uygulama, Google Maps entegrasyonu ve donanım izinleri (Konum, Kamera) gerektirir.

* **Bağımlılıklar:** `campus_app/` dizininde `flutter pub get` komutu ile gerekli paketleri indirin.
* **Harita Entegrasyonu:** `AndroidManifest.xml` (Android) ve `AppDelegate.swift` (iOS) dosyalarına kendi **Google Maps API Key**'inizi ekleyin.
* **API Bağlantısı:** Uygulama içerisindeki API URL bilgisini kendi **Ngrok** adresinizle güncelleyerek tünel üzerinden iletişimi sağlayın.
* **Çalıştırma:** Cihazınız bağlıyken terminale şu komutu girin:
    ```bash
    flutter run
    ```

</details>

---
*Developed by Ömer Basmacı - 2026*
