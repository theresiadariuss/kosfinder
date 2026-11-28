# Daftar Rincian Task (TASKS.md) - KosFinder

Dokumen ini memuat daftar tugas implementasi bertahap menggunakan pendekatan **Vertical Slice Architecture**. Setiap task dirancang spesifik dengan batasan file yang ketat. Setiap slice selesai menghasilkan aplikasi yang stabil dan dapat dijalankan (*runnable*).

---

## Ringkasan Slice

- **Slice 1**: Katalog Publik & Detail Kos (US01, US02, Info Pengembang)
- **Slice 2**: Pencarian & Penyaringan Kos (US03)
- **Slice 3**: Autentikasi Pemilik Kos (US04)
- **Slice 4**: Manajemen CRUD Kos Milik Sendiri & Pengujian RLS (US05, US06, US07)
- **Slice 5**: [Fitur Bonus] Ketersediaan Kamar (US08)

---

## Slice 1: Daftar dan Detail Kos

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T01** | Setup dependensi `provider` & `supabase_flutter`, konfigurasi `--dart-define`, dan inisialisasi Supabase di `main.dart` | US01-AC4 | `pubspec.yaml`, `lib/main.dart`, `lib/core/config/app_config.dart`, `README.md` | `flutter pub get`, `flutter analyze` bersih, aplikasi berjalan tanpa crash | Done |
| **T02** | Buat model data `Kos` beserta fungsi parsing JSON dari tabel PostgreSQL Supabase dan formatting data | US01-AC1, US02-AC1 | `lib/models/kos.dart`, `test/models/kos_test.dart` | `flutter test test/models/kos_test.dart` lulus 100% | Done |
| **T03** | Buat `KosRepository` (query `fetchAll`, `fetchById`), `KosListProvider` (state data, loading, error, retry), dan daftarkan di `main.dart` | US01-AC1, US01-AC2, US01-AC3 | `lib/repositories/kos_repository.dart`, `lib/providers/kos_list_provider.dart`, `lib/main.dart`, `test/providers/kos_list_provider_test.dart` | `flutter test test/providers/kos_list_provider_test.dart` lulus | Done |
| **T04** | Buat halaman `KosListScreen` berisi kartu kos publik, penanganan state kosong, dan state error dengan tombol coba lagi | US01-AC1, US01-AC2, US01-AC3, US01-AC4 | `lib/screens/kos_list_screen.dart`, `lib/widgets/kos_card.dart`, `test/screens/kos_list_screen_test.dart` | Widget test lulus, buka aplikasi di emulator/device dan verifikasi daftar kos muncul | Done |
| **T04A** | Pasang `KosListScreen` sebagai `home` di `KosFinderApp` agar daftar kos tampil di aplikasi | US01-AC1, US01-AC2, US01-AC3 | `lib/main.dart`, `test/widget_test.dart` | Jalankan aplikasi dengan `--dart-define` asli; daftar kos tampil dari Supabase; internet dimatikan menampilkan pesan error dan tombol Coba Lagi, tidak crash | Done |
| **T05** | Buat halaman `KosDetailScreen` menampilkan info lengkap kos, tombol salin nomor WhatsApp ke clipboard dengan SnackBar, dan navigasi dari kartu kos ke detail | US02-AC1, US02-AC2 | `lib/screens/kos_detail_screen.dart`, `lib/screens/kos_list_screen.dart`, `lib/widgets/kos_card.dart`, `test/screens/kos_detail_screen_test.dart` | Ketuk kartu kos, verifikasi navigasi ke detail berjalan, rincian tampil, ketuk tombol salin dan pastikan nomor tersalin & SnackBar muncul | Done |
| **T06** | Buat halaman `AboutScreen` (identitas pengembang: 2415051116 - Theresia Darius) dan hubungkan tombol navigasinya di `KosListScreen` | Aturan AGENTS.md Bagian 7 | `lib/screens/about_screen.dart`, `lib/screens/kos_list_screen.dart`, `test/screens/about_screen_test.dart` | Ketuk ikon About di AppBar, pastikan nama dan NIM tampil tepat | Done |

---

## Slice 2: Pencarian dan Filter Kos

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T07** | Implementasikan fungsi pencarian kata kunci case-insensitive (nama & area) dan filter (harga sewa maks & checklist fasilitas) di provider | US03-AC1, US03-AC2, US03-AC3, US03-AC4 | `lib/providers/kos_list_provider.dart`, `test/providers/kos_list_provider_test.dart` | `flutter test test/providers/kos_list_provider_test.dart` lulus untuk skenario filter & search | Done |
| **T08** | Integrasikan kolom Search Bar dan BottomSheet filter interaktif di `KosListScreen` serta pesan saat hasil kosong | US03-AC1, US03-AC2, US03-AC3, US03-AC4 | `lib/screens/kos_list_screen.dart`, `lib/widgets/filter_bottom_sheet.dart`, `test/screens/kos_list_screen_test.dart` | Ketik kata kunci "singaraja", terapkan filter harga & fasilitas di UI, pastikan list terfilter akurat atau pesan kosong tampil | Done |

---

## Slice 3: Autentikasi Pemilik Kos

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T09** | Buat `AuthRepository` (Supabase Auth signUp, signIn, signOut, currentUser), `AuthProvider` (manajemen sesi, loading, galat), dan daftarkan di `main.dart` | US04-AC1, US04-AC2, US04-AC3, US04-AC4 | `lib/repositories/auth_repository.dart`, `lib/providers/auth_provider.dart`, `lib/main.dart`, `test/providers/auth_provider_test.dart` | `flutter test test/providers/auth_provider_test.dart` lulus | Done |
| **T10** | Buat UI `LoginScreen` dan `RegisterScreen` dengan validasi form (email valid, sandi min. 6 karakter), penanganan pesan error, serta tombol "Masuk Pemilik" di `KosListScreen` | US04-AC1, US04-AC2, US04-AC3 | `lib/screens/login_screen.dart`, `lib/screens/register_screen.dart`, `lib/screens/kos_list_screen.dart`, `test/screens/login_screen_test.dart` | Coba tombol "Masuk Pemilik" di KosListScreen, input email/sandi salah dan verifikasi pesan muncul; uji daftar & login akun baru ke Supabase | Done |
| **T11** | Buat kerangka `OwnerDashboardScreen` dengan aksi logout yang mengembalikan sesi pemilik ke status pencari publik | US04-AC2, US04-AC4 | `lib/screens/owner_dashboard_screen.dart`, `lib/screens/kos_list_screen.dart`, `test/screens/owner_dashboard_screen_test.dart` | Login berhasil diarahkan ke dashboard; tekan tombol logout kembali ke `KosListScreen` sebagai pencari | Done |

---

## Slice 4: Manajemen Kos Milik Sendiri (Tambah, Ubah, Hapus)

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T12** | Implementasikan metode CRUD (`fetchByOwner`, `insert`, `update`, `delete`) pada `KosRepository`, buat `OwnerKosProvider`, dan daftarkan di `main.dart` | US05-AC1, US06-AC1, US07-AC2 | `lib/repositories/kos_repository.dart`, `lib/providers/owner_kos_provider.dart`, `lib/main.dart`, `test/providers/owner_kos_provider_test.dart` | `flutter test test/providers/owner_kos_provider_test.dart` lulus | Done |
| **T13** | Buat form `KosFormScreen` untuk tambah kos (validasi nama wajib & harga > 0) dan tampilkan daftar kos milik pemilik yang login (`fetchByOwner`) di `OwnerDashboardScreen` | US05-AC1, US05-AC2 | `lib/screens/kos_form_screen.dart`, `lib/screens/owner_dashboard_screen.dart`, `test/screens/kos_form_screen_test.dart` | Isi form tambah kos di device, simpan, pastikan data baru muncul di dashboard pemilik dan katalog publik | Done |
| **T14** | Implementasikan mode edit pada `KosFormScreen` dengan preload data yang ada dan pembaruan data ke backend | US06-AC1, US06-AC2 | `lib/screens/kos_form_screen.dart`, `lib/screens/owner_dashboard_screen.dart`, `test/screens/kos_form_screen_test.dart` | Ubah harga dan fasilitas kos di device, simpan, pastikan data terbarui; verifikasi penolakan RLS jika diedit user lain | Done |
| **T15** | Implementasikan tombol hapus dengan dialog konfirmasi ("Apakah Anda yakin ingin menghapus kos ini secara permanen?") dan hard delete | US07-AC1, US07-AC2, US07-AC3 | `lib/screens/owner_dashboard_screen.dart`, `test/screens/owner_dashboard_screen_test.dart` | Tekan hapus, verifikasi dialog konfirmasi muncul, konfirmasi hapus dan pastikan data hilang permanen dari database | Done |
| **T16** | Uji manual RLS dengan dua akun: Pemilik B login lalu mencoba mengubah dan menghapus kos milik Pemilik A dan hasilnya ditolak (0 baris terubah) | US06-AC2, US07-AC3 | Tidak ada (hanya mencatat hasil) | Jalankan skenario uji dua akun di device/test script, verifikasi 0 baris terubah saat mutasi kos akun lain | Pending |

---

## Slice 5 (Fitur Bonus): Ketersediaan Kamar

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T17** | Tambahkan kolom `availableRooms` pada model `Kos`, input kamar di `KosFormScreen`, dan penanganan mutasinya di provider | US08-AC3 | `lib/models/kos.dart`, `lib/screens/kos_form_screen.dart`, `lib/providers/owner_kos_provider.dart`, `test/models/kos_test.dart` | `flutter test` lulus, form menerima input jumlah kamar (angka integer >= 0) | Pending |
| **T18** | Perbarui tampilan kartu kos di `KosListScreen` dan detail di `KosDetailScreen` untuk label "Tersedia X kamar" atau badge "Penuh" | US08-AC1, US08-AC2 | `lib/widgets/kos_card.dart`, `lib/screens/kos_detail_screen.dart`, `test/widgets/kos_card_test.dart` | Verifikasi kos dengan kamar > 0 menampilkan jumlah kamar dan kos dengan kamar = 0 menampilkan badge "Penuh" | Pending |
