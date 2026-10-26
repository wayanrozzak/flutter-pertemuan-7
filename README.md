# Course Data Manager — Pertemuan 7

## Deskripsi
Course Data Manager adalah aplikasi Flutter untuk mengelola data mata kuliah. Proyek ini dikembangkan dalam praktikum Flutter Pertemuan 7 dengan backend Supabase.

## Identitas Mahasiswa
- Nama: Wayan Muizul Rozzak
- NIM: 2415051111

## Fitur
- Membaca data mata kuliah dari Supabase.
- Menambahkan mata kuliah.
- Mengubah data mata kuliah.
- Menghapus mata kuliah.
- Menampilkan daftar mata kuliah favorit.
- Menangani loading, error, dan respons HTTP pada layanan terkait.
- Menggunakan Provider untuk pengelolaan state.

## Teknologi
- Flutter dan Dart
- Provider
- Supabase
- HTTP
- Git dan GitHub

## Arsitektur Aplikasi
Alur pengelolaan data utama:

Screen/UI -> Provider -> Repository -> Service -> Supabase

- **Screen/UI:** menampilkan data dan menerima interaksi pengguna.
- **Provider:** mengelola state aplikasi.
- **Repository:** menjadi abstraksi akses data.
- **Service:** menangani komunikasi dengan backend.
- **Supabase:** menyimpan data mata kuliah.

## Struktur Data
Tabel utama: `public.courses`

Kolom yang digunakan:
- `id`
- `code`
- `title`
- `credits`
- `status`
- `created_at`

## Persiapan dan Menjalankan Aplikasi
Pastikan Flutter SDK sudah terpasang dan perangkat Android atau emulator tersedia.

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Konfigurasi Backend
Aplikasi menggunakan proyek Supabase yang telah dikonfigurasi pada kode aplikasi.

- URL proyek: `https://ftbpxopkphlgbbtdomxz.supabase.co`
- Tabel data: `public.courses`

Aplikasi klien hanya boleh menggunakan publishable key. Jangan memasukkan `service_role` key atau secret key ke aplikasi Flutter maupun repository GitHub. Keamanan data harus tetap ditegakkan melalui konfigurasi Row Level Security (RLS) dan kebijakan akses Supabase.

## Riwayat Integrasi REST API
Pada tahap awal praktikum, proyek juga mempelajari endpoint REST API berikut:

`https://course-api-pearl.vercel.app/courses`

Backend utama aplikasi pada tahap akhir adalah Supabase.

## Pengujian dan Pemeriksaan
Jalankan `flutter analyze` untuk memeriksa analisis kode dan `flutter test` untuk menjalankan pengujian otomatis.

Status hasil pengujian terakhir sebelum finalisasi dokumentasi: analisis kode berhasil dan seluruh 4 pengujian otomatis lulus.
