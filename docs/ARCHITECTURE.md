# Dokumen Arsitektur Sistem (ARCHITECTURE.md) - KosFinder

Dokumen ini menjelaskan arsitektur teknis, pola desain, alur data, rancangan basis data, dan prosedur operasional untuk aplikasi **KosFinder**.

---

## 1. Arsitektur Komponen & Pola Desain

Aplikasi menerapkan arsitektur berlapis sederhana dengan pola **Screen - Provider - Repository - Supabase Client** untuk memisahkan UI, logika bisnis, dan akses data.

### Tugas Komponen & Pemetaan User Story

| Komponen | Layer | Tanggung Jawab / Tugas | User Story |
| :--- | :--- | :--- | :--- |
| **KosListScreen** | Screen | Menampilkan katalog kos publik, tombol masuk pemilik, pencarian teks, filter harga & fasilitas, serta penanda kamar penuh. | US01, US03, US04, US08 |
| **KosDetailScreen** | Screen | Menampilkan rincian lengkap kos dan tombol salin nomor WhatsApp pemilik ke clipboard. Navigasi kembali ke daftar kos. | US02, US08 |
| **LoginScreen & RegisterScreen** | Screen | Formulir autentikasi pemilik kos via email dan password. | US04 |
| **OwnerDashboardScreen** | Screen | Menampilkan daftar kos milik pemilik yang sedang login beserta aksi tambah, edit, dan hapus. | US04, US06, US07, US08 |
| **KosFormScreen** | Screen | Formulir input data kos baru dan pembaruan data kos yang sudah ada. | US05, US06, US08 |
| **AboutScreen** | Screen | Menampilkan informasi aplikasi dan identitas pengembang (NIM: 2415051116, Nama: Theresia Darius). | Aturan AGENTS.md |
| **AuthProvider** | Provider | Mengelola state autentikasi (sesi login/logout, data user aktif, loading, dan pesan error). | US04 |
| **KosListProvider** | Provider | Mengelola state daftar kos publik, parameter filter (harga & fasilitas), kata kunci pencarian, serta status koneksi/error. | US01, US03, US08 |
| **OwnerKosProvider** | Provider | Mengelola state CRUD kos milik pemilik terautentikasi dan mutasi data kos lokal. | US05, US06, US07, US08 |
| **AuthRepository** | Repository | Mengabstraksi komunikasi dengan Supabase Auth (`signIn`, `signUp`, `signOut`, `currentUser`). | US04 |
| **KosRepository** | Repository | Mengabstraksi query Supabase Database (`fetchAll`, `fetchById`, `fetchByOwner`, `insert`, `update`, `delete`). | US01, US02, US03, US05, US06, US07, US08 |
| **SupabaseClient** | Backend Client | Instance SDK Supabase resmi yang bertransaksi langsung ke backend melalui koneksi HTTPS/PostgREST. | Semua Story |

---

## 2. Daftar Layar dan Alur Navigasi

Aplikasi menggunakan alur navigasi deklaratif/imperatif sederhana berbasis Material Navigator bawaan Flutter.

```
                               +-------------------+
                               |   KosListScreen   | <======================+
                               |   (Home Publik)   |                        |
                               +---+-----+-----+---+                        |
         Pilih item / Kembali      |     |     |  Buka About                |
   +-------------------------------+     |     +------------> [AboutScreen] |
   |                                     |                                  |
   v                                     v Tombol Masuk Pemilik             |
+-------------------+          +-------------------+                        |
|  KosDetailScreen  |          |    LoginScreen    | <---+                  |
|  (Detail & Salin) |          +---------+---------+     |                  |
+-------------------+                    |               | Beralih formulir |
                           Sukses Login  |               v                  |
                                         |       +----------------+         |
                                         |       | RegisterScreen |         |
                                         |       +-------+--------+         |
                                         |               | Sukses Daftar    |
                                         +-------+-------+                  |
                                                 v                          |
                                    +--------------------------+            |
                                    |   OwnerDashboardScreen   |            |
                                    | (Kelola Kos Milik Sendiri)            |
                                    +------------+-------------+            |
                                                 |                          |
                                  +--------------+--------------+           |
                                  |                             | Logout    |
                      Tambah/Edit |                             +-----------+
                                  v
                        +-------------------+
                        |   KosFormScreen   |
                        |  (Tambah / Edit)  |
                        +-------------------+
```

---

## 3. Rencana Basis Data & Row Level Security (RLS)

### Tabel: `kos`

| Kolom | Tipe Data | Keterangan & Batasan | Story |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key, `DEFAULT gen_random_uuid()` | US01-US08 |
| `owner_id` | `UUID` | Foreign Key ke `auth.users(id)` ON DELETE CASCADE, NOT NULL | US04-US07 |
| `name` | `TEXT` | Nama kos, NOT NULL | US01, US05 |
| `area` | `TEXT` | Nama area/wilayah kos (misal: "Singaraja"), NOT NULL | US01, US03, US05 |
| `address` | `TEXT` | Alamat lengkap kos, NOT NULL | US02, US05 |
| `description` | `TEXT` | Deskripsi fasilitas dan ketentuan kos, NOT NULL | US02, US05 |
| `price_per_month` | `BIGINT` | Harga sewa bulanan (angka integer, CHECK `price_per_month > 0`), NOT NULL | US01, US03, US05 |
| `gender_type` | `TEXT` | Tipe penghuni: 'putra', 'putri', 'campur', NOT NULL | US01, US05 |
| `has_wifi` | `BOOLEAN` | Fasilitas WiFi, NOT NULL, DEFAULT false | US01, US03, US05 |
| `has_ac` | `BOOLEAN` | Fasilitas AC, NOT NULL, DEFAULT false | US01, US03, US05 |
| `has_private_bathroom` | `BOOLEAN` | Fasilitas Kamar Mandi Dalam, NOT NULL, DEFAULT false | US01, US03, US05 |
| `includes_electricity` | `BOOLEAN` | Fasilitas Listrik Termasuk, NOT NULL, DEFAULT false | US01, US03, US05 |
| `whatsapp_number` | `TEXT` | Nomor kontak WhatsApp pemilik, NOT NULL | US02, US05 |
| `available_rooms` | `INTEGER` | Jumlah kamar tersedia (angka integer, CHECK `available_rooms >= 0`), NOT NULL, DEFAULT 1 | US08 |
| `created_at` | `TIMESTAMPTZ`| Waktu pencatatan, NOT NULL, DEFAULT now() | US01 |
| `updated_at` | `TIMESTAMPTZ`| Waktu terakhir diubah, NOT NULL, DEFAULT now() | US06 |

### Relasi
- Relasi `many-to-one`: Setiap record pada tabel `kos` terhubung ke satu pengguna pemilik di tabel `auth.users` via `kos.owner_id = auth.users.id`.

### Aturan Akses (Row Level Security / RLS)
Row Level Security diaktifkan penuh pada tabel `kos` untuk menjamin keamanan di level backend:
1. **Melihat (SELECT)**: Terbuka untuk semua pengguna (publik unauthenticated `anon` dan authenticated `authenticated`). Siapa saja dapat melihat katalog kos.
2. **Menambah (INSERT)**: Hanya pengguna terautentikasi (`authenticated`). Aturan `auth.uid() = owner_id` memastikan pemilik hanya bisa mendaftarkan kos atas namanya sendiri.
3. **Mengubah (UPDATE)**: Hanya pemilik kos terkait (`auth.uid() = owner_id`). Pengguna lain ditolak oleh backend.
4. **Menghapus (DELETE)**: Hanya pemilik kos terkait (`auth.uid() = owner_id`). Pengguna lain ditolak oleh backend.

---

## 4. Konfigurasi Kredensial via `--dart-define`

Untuk mencegah kebocoran kredensial, URL dan Anon Key Supabase **tidak pernah ditulis langsung di source code**. Kredensial dibaca saat kompilasi menggunakan `String.fromEnvironment`:

```dart
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
}
```

Menjalankan aplikasi secara lokal:
```bash
flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=sb_publishable_xxxx
```

---

## 5. Prosedur Rilis Aplikasi

### A. Pembuatan Binary APK Android
Build rilis APK mandiri (*fat APK*) dieksekusi dengan perintah:
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_xxxx
```
Output berkas biner terletak pada:
`build/app/outputs/flutter-apk/app-release.apk`

### B. Publikasi GitHub Release
1. Berikan tag versi git pada commit yang telah lulus Definition of Done (DoD):
   ```bash
   git tag -a v0.1.0 -m "Release KosFinder v0.1.0"
   git push origin v0.1.0
   ```
2. Buat rilis baru di GitHub melalui menu **Releases > Draft a new release** pada repositori [https://github.com/theresiadariuss/kosfinder](https://github.com/theresiadariuss/kosfinder).
3. Unggah berkas `app-release.apk`, cantumkan changelog rilis v0.1.0, dan publikasikan rilis.

---

## 6. Daftar Package Eksternal yang Dibutuhkan

Sesuai prinsip kesederhanaan (KISS) dan aturan `AGENTS.md`, aplikasi hanya menggunakan dependensi esensial berikut:

| Package | Versi Rekomendasi | Alasan Pemilihan & Kegunaan | Story Terkait |
| :--- | :--- | :--- | :--- |
| **`provider`** | `^6.1.2` | State management resmi proyek, reaktif, ringan, efisien, dan mudah diuji tanpa boilerplate berlebih. | US01 - US08 |
| **`supabase_flutter`** | `^2.8.0` | SDK resmi Flutter untuk Supabase yang menyediakan integrasi PostgREST database query dan Supabase Auth (token session storage otomatis). | US01 - US08 |

*Catatan: Fitur salin kontak ke clipboard (US02) tidak memerlukan package pihak ketiga tambahan karena telah ditangani langsung oleh modul bawaan Flutter SDK: `Clipboard.setData()` dari `package:flutter/services.dart`.*
