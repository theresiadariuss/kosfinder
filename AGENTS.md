# Aturan Kerja Agen AI (AGENTS.md) - KosFinder

Dokumen ini berisi panduan, batasan, dan aturan kerja baku bagi agen AI dalam mengembangkan dan memelihara proyek **KosFinder**.

---

## 1. Konteks Proyek & Dokumen Acuan

- **Nama Proyek**: KosFinder
- **Deskripsi**: Aplikasi Android pencari kos yang memudahkan pencari kos menemukan hunian serta pemilik kos mengelola properti mereka.
- **Repository**: [https://github.com/theresiadariuss/kosfinder](https://github.com/theresiadariuss/kosfinder)
- **Dokumen Acuan**:
  - `docs/PRD.md` — Product Requirement Document (cakupan fitur, user persona, alur bisnis).
  - `docs/ARCHITECTURE.md` — Struktur arsitektur aplikasi, tata letak folder, dan konvensi teknis.
  - `docs/TASKS.md` — Daftar rincian task, status pengerjaan, dan checklist implementasi.

---

## 2. Cara Kerja Agen

1. **Satu Task Per Permintaan**: Fokus hanya pada satu task/fitur yang diminta dalam satu sesi atau prompt. Jangan melompat ke task berikutnya sebelum task aktif selesai dan diverifikasi.
2. **Batasan Perubahan File**: Jangan mengubah file di luar cakupan task yang sedang dikerjakan kecuali benar-benar diperlukan dan disepakati.
3. **Rencanakan Perubahan Besar**: Untuk perubahan besar (refactoring struktural, penambahan modul inti, migrasi arsitektur), buat dan ajukan rencana langkah kerja terlebih dahulu sebelum menulis kode.
4. **Prinsip Kesederhanaan (KISS)**: Pilih solusi yang paling sederhana, bersih, mudah dibaca, dan mudah dirawat. Hindari over-engineering.
5. **Persetujuan Penambahan Package**: Dilarang menambah package/dependency baru di `pubspec.yaml` tanpa izin eksplisit dari pengguna.

---

## 3. Stack Teknologi

- **Framework**: Flutter
- **State Management**: Provider
- **Backend & Database**: Supabase

---

## 4. Keamanan & Proteksi Data

- **Tidak Ada Kredensial di Kode**: Dilarang mencantumkan API key, secret token, password, atau kredensial sensitif secara hardcoded di dalam source code.
- **Batasan Key Supabase**: Key berlevel `service_role` **TIDAK PERNAH** boleh dipakai atau disertakan di aplikasi klien (mobile). Gunakan hanya `anon key` publik dengan kebijakan keamanan yang ketat.
- **Row Level Security (RLS)**: Seluruh hak akses, validasi perizinan baca, tulis, update, dan delete data ditegakkan langsung di level database Supabase menggunakan Row Level Security (RLS).

---

## 5. Standar Git & Commit

- **Satu Task Satu Commit**: Setiap penyelesaian satu task harus dipisahkan ke dalam commit mandiri.
- **Pesan Commit**: Pesan commit wajib mencantumkan ID task secara jelas, misalnya:
  - `feat(TASK-01): implementasi halaman login`
  - `fix(TASK-03): perbaiki filter harga pencarian kos`

---

## 6. Definition of Done (DoD)

Sebuah task dianggap selesai hanya jika memenuhi kriteria berikut:

1. `flutter analyze` bersih (tidak ada warning atau error baru).
2. `flutter test` lulus tanpa kegagalan.
3. Aplikasi dapat dijalankan dengan baik di device / emulator tanpa crash.
4. **Laporan Pengujian**: Agen wajib melaporkan ringkasan apa saja yang telah diuji serta secara transparan menyebutkan skenario/bagian apa saja yang belum sempat diuji.

---

## 7. Informasi Pengembang (Halaman About)

Pada halaman **About** aplikasi, wajib menampilkan identitas pengembang:
- **NIM**: 2415051116
- **Nama**: Theresia Darius
