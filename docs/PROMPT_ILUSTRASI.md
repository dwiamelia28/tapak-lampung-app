# Panduan Ilustrasi HD untuk TAPAK LAMPUNG

Aplikasi sudah punya ilustrasi vektor bawaan. Untuk tampilan setara gambar referensi,
buat gambar dengan generator gambar AI (atau ilustrator), simpan di `assets/illustrations/`
dengan NAMA PERSIS di bawah. Aplikasi otomatis memakainya jika ada, dan kembali ke vektor jika tidak.
Setelah menaruh file: `flutter run` ulang (atau hot restart).

| File | Isi | Ukuran saran |
|---|---|---|
| `guide_male.png` | Karakter laki-laki berbusana adat Lampung, melambai, latar TRANSPARAN | 800x1040 PNG |
| `guide_female.png` | Karakter perempuan bermahkota siger, melambai, latar TRANSPARAN | 800x1040 PNG |
| `scene_bg.png` | Pemandangan Lampung (rumah adat panggung, bukit, langit hangat), TANPA karakter | 1200x700 |
| `chapter_rumah.png` | Nuwo Sesat, tampak depan, latar pemandangan | 1250x1000 (rasio 1.25:1) |
| `chapter_kain.png` | Kain Tapis bersulam emas + siger | 1250x1000 |
| `chapter_seni.png` | Penari + gamolan di panggung | 1250x1000 |
| `chapter_kuliner.png` | Seruit, kopi, engkak di meja | 1250x1000 |
| `map_bg.png` | Peta laut bergaya ilustrasi (tanpa pulau; pulau digambar aplikasi) | 1080x2400 |
| `trophy.png` | Piala emas, latar transparan | 600x600 |

## Contoh prompt (sesuaikan)
Gaya umum: "premium 2D illustrated cultural adventure game art, warm cream, terracotta, deep forest green,
maroon and gold palette, soft shading, clean outlines, high detail, Indonesian Lampung culture".

- Karakter: "full-body 2D character, young Indonesian man in traditional Lampung attire (dark jacket, red
  songket/tapis sarong with gold trim, maroon headcloth), waving, friendly, transparent background".
- Karakter perempuan: "... woman wearing the gold siger crown, maroon kebaya, tapis sarong with gold embroidery ...".
- Bab: "illustrated scene of Nuwo Sesat, traditional Lampung stilt-house hall, front view, tropical hills,
  warm sunlight, no text, aspect ratio 5:4".

## Penting
- Jangan tulis teks di dalam gambar (teks di aplikasi dibuat oleh kode).
- Pakai PNG/WebP, usahakan < 1 MB per file agar aplikasi tetap ringan.
- Jika gambar bab diganti, posisi titik interaktif (dx, dy di Firestore, 0..1) mungkin perlu disesuaikan.
- Periksa akurasi busana dan arsitektur dengan sumber resmi; gambar AI bisa keliru secara budaya.
