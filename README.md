# KosFinder

Aplikasi Flutter pencari kos untuk memudahkan calon penghuni menemukan informasi kos secara cepat dan terstruktur tanpa perlu login.

## Fitur Tersedia
- **Daftar Kos Publik**: Menampilkan daftar kos beserta nama, area, harga sewa per bulan, tipe penghuni, dan ikon fasilitas.
- **Detail Kos**: Menampilkan informasi lengkap kos (alamat, deskripsi, fasilitas) serta tombol salin nomor WhatsApp pemilik ke clipboard.
- **Pencarian**: Pencarian kata kunci *case-insensitive* berdasarkan nama kos atau area.
- **Filter**: Penyaringan kos berdasarkan harga sewa maksimal per bulan dan checklist fasilitas (WiFi, AC, Kamar Mandi Dalam, Listrik Termasuk).
- **Halaman About**: Menampilkan informasi aplikasi dan identitas pengembang.

## Cara Menjalankan
Aplikasi memerlukan konfigurasi backend Supabase melalui `--dart-define` saat menjalankan build (ganti nilai contoh di bawah dengan URL dan Anon Key proyek Supabase Anda):

```bash
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://contoh-project.supabase.co --dart-define=SUPABASE_ANON_KEY=contoh_anon_key_palsu
```

Untuk menjalankan pengujian unit dan widget test (tanpa koneksi Supabase):

```bash
flutter analyze
flutter test
```

## Batasan Versi Saat Ini
- Autentikasi pemilik kos (Registrasi & Login) belum diimplementasikan.
- Manajemen CRUD data kos oleh pemilik (Tambah, Ubah, Hapus) belum diimplementasikan.
