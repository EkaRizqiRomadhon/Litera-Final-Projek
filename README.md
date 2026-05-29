<div align="center">

# 📚 Litera
### *Membaca Tanpa Batas, Kapan Saja, Di Mana Saja.*

**Aplikasi Perpustakaan Digital & Manajemen Buku berbasis Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%26%20Auth-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Supabase](https://img.shields.io/badge/Supabase-Storage-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Cloudinary](https://img.shields.io/badge/Cloudinary-Media%20Upload-3448C5?logo=cloudinary&logoColor=white)](https://cloudinary.com)

</div>

---

## 🧾 Deskripsi Aplikasi

**Litera** adalah aplikasi mobile perpustakaan digital yang dibangun menggunakan **Flutter**. Aplikasi ini memungkinkan pengguna untuk menjelajahi, menyimpan, dan membaca koleksi buku dalam format PDF secara langsung dari cloud storage.

Litera hadir sebagai solusi *all-in-one* bagi pecinta buku yang ingin memiliki rak buku digital pribadi yang tersinkronisasi di cloud, dapat diakses dari perangkat mana pun, dengan antarmuka yang modern dan responsif.

---

## ✨ Fitur Utama

### 👤 Fitur Pengguna
| Halaman | Deskripsi |
|---|---|
| 🏠 **Home (Beranda)** | Menampilkan rekomendasi buku dan riwayat buku terakhir yang dibaca |
| 🔍 **Explore** | Mencari dan menjelajahi koleksi buku berdasarkan kategori genre |
| 📚 **Koleksi (Library)** | Rak buku digital pribadi: daftar bookmark dan riwayat bacaan |
| 👤 **Profil** | Manajemen akun: ubah foto profil, nama, dan pengaturan aplikasi |
| 📖 **PDF Reader** | Membaca buku langsung di dalam aplikasi dari Supabase Storage |

### 🛡️ Fitur Admin Panel
| Halaman | Deskripsi |
|---|---|
| 📊 **Dashboard Admin** | Statistik jumlah buku dan ringkasan data aplikasi |
| 📚 **Manajemen Buku** | Tambah, edit, dan hapus buku dari katalog internal (CRUD) |
| 📝 **Formulir Buku** | Input metadata buku dan upload cover buku ke cloud |

---

## ⚙️ Teknologi & Layanan (Tech Stack)

```
Flutter (Dart)           → Framework utama aplikasi mobile
Firebase Authentication  → Sistem login, registrasi, dan keamanan akun
Firebase Firestore       → Database cloud real-time (bookmark, riwayat, rating)
Supabase Storage         → Cloud storage untuk file PDF buku & cover buku
Cloudinary API           → Cloud storage untuk upload & manajemen foto profil
```

### 📦 Package Utama

| Package | Kegunaan |
|---|---|
| `provider` | State management |
| `cloud_firestore` | Database real-time |
| `firebase_auth` | Autentikasi pengguna |
| `syncfusion_flutter_pdfviewer` | Pembaca PDF bawaan |
| `cached_network_image` | Cache gambar dari network |
| `google_fonts` | Tipografi modern |
| `shared_preferences` | Penyimpanan lokal pengaturan |
| `image_picker` | Pilih gambar dari galeri |

---

## 🗂️ Struktur Project

```
lib/
├── core/               # Konstanta, warna, dan tema aplikasi
├── l10n/               # Lokalisasi (Bahasa Indonesia & Inggris)
├── models/             # Model data (BookModel, UserProfile, dll)
├── pages/              # Halaman-halaman utama aplikasi
│   ├── admin/          # Admin Panel (Dashboard, Manajemen Buku)
│   ├── dashboard_page.dart
│   ├── explore_page.dart
│   ├── library_page.dart
│   ├── profile_page.dart
│   └── book_reader_page.dart
├── providers/          # State management (BookProvider)
├── services/           # Layanan API & business logic
│   ├── book_service.dart
│   ├── local_book_service.dart
│   ├── bookmark_service.dart
│   ├── cloudinary_service.dart
│   └── rating_service.dart
└── widgets/            # Komponen UI yang dapat digunakan ulang
```

---

## 🚀 Cara Menjalankan Aplikasi

### Prasyarat
- Flutter SDK `^3.x`
- Dart SDK `^3.x`
- Android Studio / VS Code
- Akun Firebase (sudah dikonfigurasi)
- Akun Supabase (sudah dikonfigurasi)

### Langkah Instalasi

```bash
# 1. Clone repositori ini
git clone https://github.com/EkaRizqiRomadhon/litera2-final-projek.git

# 2. Masuk ke direktori project
cd litera2-final-projek

# 3. Install dependensi
flutter pub get

# 4. Jalankan aplikasi (mode debug)
flutter run

# 5. Build APK (mode release)
flutter build apk --release
```

---

## 🔑 Konfigurasi Layanan Cloud

### Firebase
File konfigurasi Firebase sudah disertakan (`google-services.json` & `GoogleService-Info.plist`).
Pastikan project Firebase Anda mengaktifkan:
- ✅ Authentication (Email/Password)
- ✅ Cloud Firestore
- ✅ Firebase Storage (opsional, untuk foto profil lama)

### Supabase
Konfigurasi Supabase diinisialisasi di `lib/main.dart`.
Pastikan bucket berikut sudah dibuat dan diset **Public** di Supabase Dashboard:
- `book` → Menyimpan file PDF buku
- `cover_book` → Menyimpan gambar sampul (cover) buku

### Cloudinary
Konfigurasi Cloudinary ada di `lib/services/cloudinary_service.dart`.
Pastikan **Upload Preset** bersifat *Unsigned* untuk upload dari mobile client.

---

## 📖 Koleksi Buku (Katalog Internal)

Buku-buku berikut tersedia langsung dalam aplikasi dan disimpan di Supabase Storage:

| Judul | Penulis | Kategori |
|---|---|---|
| Cantik Itu Luka | Eka Kurniawan | Sastra Indo, Novel |
| Ronggeng Dukuh Paruk | Ahmad Tohari | Sastra Indo, Novel |
| Filosofi Teras | Henry Manampiring | Filsafat |
| Sejarah Dunia yang Disembunyikan | Jonathan Black | Sejarah |
| Fundamentals of Engineering Thermodynamics | Moran et al. | Teknologi, Sains |
| Konflik dan Kolaborasi | Kemendikbud | Edukasi, Sejarah |
| Broken Strings | Aurelie Moeremans | Novel, Romance |
| Bumi Manusia | Pramoedya Ananta Toer | Novel, Sejarah |
| Laskar Pelangi | Andrea Hirata | Novel, Fiksi |
| Negeri 5 Menara | Ahmad Fuadi | Novel, Inspirasi |

---

## 👥 Tim Pengembang

> Aplikasi ini dikembangkan sebagai proyek akhir.

1. Eka Rizqi Romadhon
2. Moch Hafidz Asrof
3. M. Abyan Herdy S.

## 📄 Lisensi

Project ini bersifat privat dan dikembangkan untuk keperluan akademis.

---

<div align="center">
  <sub>Dibuat dengan ❤️ menggunakan Flutter & Firebase</sub>
</div>
