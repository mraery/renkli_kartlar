# 🗂️ Renkli Kartlar - Flutter Bilgi Kartı & Çalışma Uygulaması

Renkli Kartlar, öğrencilerin ve sınavlara (YKS, KPSS, LGS, DGS vb.) hazırlananların konuları hızlı, akılda kalıcı ve eğlenceli bir şekilde tekrar etmesini sağlayan modern, yerel bir **Flutter Flashcard** uygulamasıdır.

---

## ✨ Öne Çıkan Özellikler

- **320+ Dolu ve Kaliteli Hazır Kart**:
  - 🧬 **Biyoloji** (40 Kart)
  - ⚛️ **Fizik** (40 Kart)
  - 🧪 **Kimya** (40 Kart)
  - 📐 **Matematik** (40 Kart)
  - 📜 **Tarih** (40 Kart)
  - 🌍 **Coğrafya** (40 Kart)
  - 📖 **Türkçe & Edebiyat** (40 Kart)
  - 🇬🇧 **İngilizce** (40 Kart)
- **Akıllı Kaydırma (Swipe Mechanics)**:
  - 👈 **Sola Fırlat**: "Tekrar Çalış" olarak işaretler ve kartı destenin sonuna ekler (öğrenene kadar tekrar çıkar).
  - 👉 **Sağa Fırlat**: "Öğrendim" olarak işaretler ve desteden tamamlanmış olarak ayrılır.
  - Canlı **`[ 🔁 TEKRAR ]`** ve **`[ ÖĞRENDİM ✅ ]`** damgaları ile haptik geri bildirim.
- **Kusursuz 3D Çevirme (Tap to Flip)**:
  - Tek dokunuşla 3D Matrix dönüş animasyonu.
  - Ön yüz ve arka yüz kesinlikle birbirine karışmaz veya arkasından sızmaz.
- **Kart Yönetimi & Özelleştirme**:
  - İstediğin kadar kendi kartını ekle, düzenle, sil.
  - 8 farklı renk teması ve 1-3 yıldızlı önem derecesi belirleme.
  - `🗑️ Bütün Kartları Sil`: Tek tıkla hazır kartları silip sadece kendi kartlarınla çalışma imkanı.
  - `📦 Hazır 320 Kartı Tekrar Yükle`: İstenildiğinde varsayılan kartları anında geri yükleme.
- **Kalıcı Hafıza & Filtreler**:
  - Kart durumları ve kendi eklediğin kartlar `shared_preferences` ile cihazında güvenle saklanır.
  - Ders kategorilerine, önem derecesine ve tekrara göre anlık filtreleme.

---

## 📱 Android APK İndirme

Hazır derlenmiş release APK dosyasını doğrudan indirip cihazınıza yükleyebilirsiniz:
- **Doğrudan İndirme:** [`apks/renkli_kartlar.apk`](apks/renkli_kartlar.apk)

---

## 🚀 Projeyi Çalıştırma

### Gereksinimler
- Flutter SDK (3.x veya üzeri)
- Dart SDK
- Android Studio veya VS Code

### Kurulum Adımları
```bash
# Bağımlılıkları yükleyin
flutter pub get

# Hata kontrolü
flutter analyze

# Uygulamayı cihazda / emülatörde çalıştırın
flutter run

# Release APK derlemek için
flutter build apk --release --no-tree-shake-icons
```

