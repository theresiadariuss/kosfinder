# Test Plan KosFinder

Pengujian dilakukan manual di emulator Android dengan backend Supabase asli.

| ID | AC terkait | Langkah | Hasil yang diharapkan | Hasil nyata | Lulus |
|---|---|---|---|---|---|
| TP01 | US01-AC1 | Buka aplikasi dengan internet aktif | Daftar kos tampil dari Supabase | Daftar kos tampil (Kos Mawar, Kos Melati, dst.) | Ya |
| TP02 | US01-AC2 | Kosongkan data kos lalu buka aplikasi | Pesan "Belum ada kos yang terdaftar" |  |  |
| TP03 | US01-AC3 | Matikan internet lalu buka aplikasi | Pesan error dan tombol Coba Lagi, tidak crash |  |  |
| TP04 | US02-AC1 | Ketuk salah satu kartu kos | Halaman detail terbuka dengan info lengkap |  |  |
| TP05 | US02-AC2 | Ketuk nomor WhatsApp di halaman detail | Nomor tersalin ke clipboard dan SnackBar tampil |  |  |
| TP06 | US03-AC1 | Cari "singaraja" lalu "Singaraja" | Hasil sama, pencarian tidak peka huruf besar-kecil | Hasil sama: Kos Mawar dan Kos Melati tampil | Ya |
| TP07 | US03-AC2 | Filter harga maksimal Rp2.000.000 | Kos dengan harga di atas batas tidak tampil | Hanya kos dengan harga di bawah batas yang tampil | Ya |
| TP08 | US03-AC3 | Centang fasilitas WiFi dan AC pada filter | Hanya kos dengan kedua fasilitas yang tampil |  |  |
| TP09 | US03-AC4 | Isi harga maksimal sangat kecil (Rp100.000) | Pesan "Tidak ada kos yang sesuai dengan kriteria pencarian" |  |  |
| TP10 | Slice 3 (login pemilik) | Register, login, logout | Sesuai AC login di PRD | Belum diimplementasikan karena kuota agen habis | Tidak |
| TP11 | Slice 4 (kelola kos) | Pemilik A mengubah kos miliknya; pemilik B mencoba mengubah kos milik A | A berhasil, B ditolak | Belum diimplementasikan karena kuota agen habis | Tidak |

## Catatan
- Slice 1 dan 2 telah diuji dan berfungsi. Slice 3 dan 4 belum dikerjakan.
- Uji keamanan dua akun pemilik (TP11) belum dapat dilakukan karena fiturnya belum ada.
