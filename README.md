## Tahap 1 — Membaca REST Endpoint dan JSON

### Informasi Endpoint
- **Base URL:** https://course-api-pearl.vercel.app
- **Endpoint:** https://course-api-pearl.vercel.app/courses
- **HTTP Method:** GET
- **Status Code:** 200 OK
- **Resource:** courses

### Hasil Pengujian
Pengujian endpoint dilakukan menggunakan PowerShell dengan perintah `Invoke-WebRequest`. Request GET berhasil dan mengembalikan status code 200 OK.

Response body berupa array JSON yang berisi 5 data course. Field yang ditemukan meliputi:
- `id`: identitas course.
- `code`: kode course.
- `title`: judul course.
- `credits`: jumlah kredit.
- `status`: status course.
- `created_at`: waktu pembuatan data.

### Contoh Data JSON
```json
{
  "id": 2,
  "code": "MOB02",
  "title": "Dart Fundamentals",
  "credits": 3,
  "status": "active",
  "created_at": "2026-10-21T03:28:09.128977Z"
}
```

### Catatan
Endpoint berhasil diakses menggunakan metode GET. Data diterima dalam format JSON dan dapat digunakan sebagai sumber data untuk pengembangan aplikasi Course Data Manager.
