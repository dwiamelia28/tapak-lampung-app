# Panduan Uji dan Catatan UTS

## PENTING: Firebase Storage tidak dipakai
Atas keputusan pengembang, aplikasi TIDAK memakai Firebase Storage (butuh paket berbayar).
Foto pengguna dikompres lalu disimpan sebagai Base64 di Cloud Firestore.
Soal UTS Pemrograman Mobile II mencantumkan Firebase Storage sebagai komponen penilaian (bobot 20).
Mekanisme Base64 di Firestore BUKAN Firebase Storage; jangan menulis di laporan bahwa foto diunggah ke
Storage. Konfirmasikan ke dosen pengampu apakah pendekatan ini diterima.

## Pemetaan fitur
| Komponen | Fitur |
|---|---|
| Authentication | Registrasi, login, logout, validasi, sesi tersimpan |
| FCM | Izin, token (Profil > Pengaturan), foreground pop-up, background, daftar notifikasi, ketuk membuka halaman |
| Notifikasi lokal terjadwal | Pengingat kunjungan, pengingat belajar (BEDA dari FCM) |
| CRUD dengan foto | Rencana Kunjungan, Jurnal Budaya (foto Base64 di Firestore) |

## Skenario uji
| No | Skenario | Hasil yang diharapkan |
|---|---|---|
| 1 | Beranda tanpa foto di assets/photos | Placeholder "Foto belum dipasang" tampil |
| 2 | Taruh nuwo_sesat.jpg lalu jalankan ulang | Foto tampil di hero |
| 3 | Buat rencana kunjungan (nama, kategori, tanggal) | Muncul di daftar dan di beranda |
| 4 | Tambah foto referensi dari galeri/kamera | Foto tampil di kartu dan detail |
| 5 | Edit tanggal rencana | Pengingat dijadwalkan ulang |
| 6 | Tandai sudah dikunjungi | Pengingat berhenti |
| 7 | Hapus rencana | Dokumen hilang, pengingat dibatalkan |
| 8 | Rencana besok, tunggu pukul 18.00 hari ini (atau 07.00 pada hari H) | Notifikasi lokal tampil |
| 9 | Daftar Belajar: tambah topik, centang dipelajari | Progres di beranda berubah |
| 10 | Pengingat Belajar: pilih jam dan hari, Simpan, lalu "Uji tampilan" | Notifikasi lokal tampil |
| 11 | Matikan pengingat / hapus pengingat | Jadwal dibatalkan |
| 12 | Login dengan akun lain | Data rencana/daftar tidak tampak (terpisah per UID) |
| 13 | Kirim test message FCM dari Console | Pop-up (foreground) dan bilah atas (background) |
| 14 | Mainkan peta, tantangan, kuis | Tampilan game tidak berubah |

## Pengumpulan
Folder `UTS-MBii-Nama-NPM` berisi laporan PDF dan folder kode tanpa `build/`.
Jangan sertakan `scripts/serviceAccountKey.json` dan `scripts/node_modules`.
