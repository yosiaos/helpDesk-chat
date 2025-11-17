# Helpdesk Chat Admin – Flutter Internship Test

## Deskripsi Proyek
Aplikasi Helpdesk Chat Admin ini dikembangkan menggunakan Flutter sebagai bagian dari Programmer Practice Test.
Proyek ini berfokus pada responsivitas, integrasi AI (Gemini API), serta role-play customer service antara Admin dan Customer (AI).

## Fitur Utama

### 1. Responsivitas UI (3-in-1 Layout)
Aplikasi menyesuaikan tampilan berdasarkan ukuran layar:
- Mobile / Tablet Portrait → layout 1 kolom (stack)
- Desktop / Tablet Landscape (> 600 px) → layout 2 kolom (split view)
Menggunakan LayoutBuilder dengan breakpoint 600.0.

### 2. Integrasi AI (Google Gemini 2.5 Flash)
Aplikasi terhubung dengan Gemini API untuk simulasi customer otomatis.
AI diprogram sebagai customer yang mengalami masalah login/sistem.
Termasuk:
- System prompt khusus
- Timeout 30 detik
- Robust error handling

### 3. Fungsionalitas Khusus (Role Reversal & Asset Lokal)
- Pesan Admin → muncul di kanan (biru)
- Pesan Customer (AI) → muncul di kiri (abu-abu)
- Jika Admin mengetik "kirim foto" → AI mengirim gambar lokal: assets/images/errortelematika.png

## Cara Menjalankan Proyek

### Prasyarat
- Flutter SDK harus terinstal
- flutter doctor harus bersih
- VSCode / Android Studio

### Langkah-langkah

#### 1. Clone Repository
```
git clone [LINK_REPO_ANDA]
cd helpdesk_test
```

#### 2. Konfigurasi Assets Lokal
Buat folder:
```
assets/images/
```
Tambahkan file:
```
errortelematika.png
```
Aktifkan pada pubspec.yaml:
```
assets:
  - assets/images/
```

#### 3. Instal Dependencies
```
flutter pub get
```

#### 4. Konfigurasi API Key
Buka:
```
lib/main.dart
```
Ganti baris:
```
final String _apiKey = "YOUR_GEMINI_API_KEY_HERE";
```

#### 5. Jalankan Aplikasi
```
flutter run
```

## Petunjuk Demonstrasi (Untuk Interviewer)
- Ketik "Halo" → AI balas ramah
- Ketik "kirim foto" → mengirim screenshot error (manual melalui asset)
- Resize window → layout berubah otomatis
- API key tidak disertakan dalam repository.

## Author
Yosia – Internship Flutter Test
