# Test Plan KosFinder

Pengujian dilakukan manual di emulator Android dengan backend Supabase asli.

| ID | AC terkait | Langkah | Hasil yang diharapkan | Hasil nyata | Lulus |
|---|---|---|---|---|---|
| TP01 | US01-AC1 | Buka aplikasi dengan internet aktif | Daftar kos tampil dari Supabase | Daftar kos tampil | Ya |
| TP02 | US01-AC2 | Kosongkan data kos lalu buka aplikasi | Pesan "Belum ada kos yang terdaftar" | Belum diuji manual |  |
| TP03 | US01-AC3 | Matikan internet lalu buka aplikasi | Pesan "Gagal memuat data, periksa koneksi internet Anda" dan tombol Coba Lagi, tidak crash | Belum diuji manual |  |
| TP04 | US01-AC4 | Buka aplikasi tanpa login dan pilih kos | Daftar kos dan detail kos dapat diakses tanpa diminta login | Belum diuji manual |  |
| TP05 | US02-AC1 | Ketuk salah satu kartu kos | Halaman detail terbuka dengan info lengkap kos | Belum diuji manual |  |
| TP06 | US02-AC2 | Ketuk nomor WhatsApp di halaman detail | Nomor tersalin ke clipboard dan SnackBar "Nomor WhatsApp berhasil disalin" tampil | Belum diuji manual |  |
| TP07 | US03-AC1 | Cari "singaraja" lalu "Singaraja" | Hasil sama, pencarian tidak peka huruf besar-kecil pada nama atau area | Hasil sama | Ya |
| TP08 | US03-AC2 | Terapkan filter harga maksimal | Kos dengan harga di atas batas tidak tampil | Kos di atas batas tidak tampil | Ya |
| TP09 | US03-AC3 | Centang filter fasilitas "WiFi" dan "AC" | Hanya kos yang memiliki minimal kedua fasilitas tersebut yang tampil | Belum diuji manual |  |
| TP10 | US03-AC4 | Terapkan pencarian/filter yang tidak cocok dengan kos mana pun | Pesan "Tidak ada kos yang sesuai dengan kriteria pencarian" | Belum diuji manual |  |
| TP11 | Slice 3 (US04-AC1 s.d. US04-AC4) | Register, login, uji login gagal, dan logout pemilik kos | Akun terdaftar/masuk ke dashboard pemilik, pesan error saat kredensial salah, logout kembali ke daftar publik | Belum diimplementasikan karena kuota agen habis | Tidak |
| TP12 | Slice 4 (US05-AC1 s.d. US07-AC3) | Pemilik A tambah/ubah/hapus kos; Pemilik B mencoba ubah/hapus kos milik A | Pemilik A berhasil CRUD; Pemilik B ditolak oleh RLS (0 baris terubah) | Belum diimplementasikan karena kuota agen habis | Tidak |

## Catatan
- Slice 1 dan 2 telah diimplementasikan. Slice 3 dan 4 belum dikerjakan.
- Uji keamanan dua akun pemilik (TP12) belum dapat dilakukan karena fiturnya belum ada.
