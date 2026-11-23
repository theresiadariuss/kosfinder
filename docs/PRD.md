# Product Requirement Document (PRD) - KosFinder (Versi 1)

## 1. Masalah & Tujuan Terukur
- **Masalah**: Informasi kos tersebar di media sosial/grup chat tanpa format standar, menyulitkan pencari membandingkan harga/fasilitas dan menyulitkan pemilik memperbarui informasi kos.
- **Tujuan Terukur**:
  1. Pencari dapat menemukan dan memfilter kos berdasarkan area, harga maksimal, dan fasilitas dalam waktu < 10 detik.
  2. Pemilik kos dapat mempublikasikan kos baru dalam waktu < 2 menit melalui alur input yang terstandarisasi.
  3. Pemilik B tidak dapat mengubah atau menghapus kos pemilik A, dibuktikan lewat uji dua akun.

## 2. Pengguna
1. **Pencari Kos**: Mahasiswa atau masyarakat umum yang mencari kos di sekitar kampus. Mengakses aplikasi tanpa perlu login/registrasi.
2. **Pemilik Kos**: Pengelola/pemilik kos yang perlu mempublikasikan, memperbarui, dan menghapus data kos miliknya. Wajib mendaftar dan login.

## 3. Scope Versi 1
### In-Scope (Fitur Inti)
- Eksplorasi daftar kos dan detail informasi kos (teks & ikon placeholder bawaan).
- Teks nomor WhatsApp pemilik pada halaman detail yang dapat disalin (*copy to clipboard*).
- Pencarian teks bebas (*case-insensitive*) pada nama kos dan area.
- Penyaringan (*filter*) berdasarkan harga sewa bulanan maksimal dan fasilitas (WiFi, AC, Kamar Mandi Dalam, Listrik Termasuk).
- Autentikasi Pemilik Kos (Register & Login) berbasis Email & Password via Supabase Auth.
- Manajemen kos oleh Pemilik: Tambah kos, Ubah data kos, dan Hapus kos (hard delete dengan dialog konfirmasi).
- Penyimpanan field tipe penghuni (Putra / Putri / Campur).
- **Fitur Bonus (Slice 5)**: Pengelolaan dan penayangan jumlah kamar tersedia (angka integer; jika 0 menampilkan label "Penuh").

### Out-of-Scope (Bukan Bagian Versi 1)
- Pembayaran online & transaksi sewa.
- Chat internal / perpesanan dalam aplikasi (*in-app chat*) & tautan otomatis `wa.me`.
- Upload foto, galeri gambar, dan input URL gambar eksternal.
- Ulasan (*review*) dan penilaian (*rating*).
- Peta digital (*Google Maps/OpenStreetMap*) dan fitur berbasis GPS/geolokasi.
- Rekomendasi berbasis AI.
- Verifikasi dokumen identitas pemilik kos.
- Filter berdasarkan tipe penghuni (tipe hanya disimpan dan ditampilkan).

## 4. Non-Functional Requirements (NFR)
- **NFR-SEC (Keamanan)**: Akses mutasi data (INSERT, UPDATE, DELETE) dibatasi ketat oleh Supabase Row Level Security (RLS), ditegakkan di backend dan bukan hanya dengan menyembunyikan tombol di aplikasi. Service role key dilarang ada di klien.
- **NFR-REL (Keandalan)**: Aplikasi menampilkan pesan galat (*error state*) yang ramah pengguna saat koneksi internet terputus dan tidak mengalami *crash*.
- **NFR-USE (Kemudahan Pakai)**: Nomor WhatsApp dapat disalin hanya dengan satu ketukan (*tap to copy*).
- **NFR-PERF (Performa)**: Waktu pemuatan daftar kos dari backend Supabase < 2 detik pada jaringan 4G stabil.
- **NFR-PRIV (Privasi)**: Data kredensial pengguna (password) terenkripsi di Supabase Auth; tidak ada data sensitif yang diekspos ke publik selain nomor kontak yang sengaja dipublikasikan pemilik.

---

## 5. User Stories & Acceptance Criteria

### US01: Melihat Daftar Kos
*Sebagai Pencari Kos, saya ingin melihat daftar seluruh kos yang tersedia tanpa harus login, agar saya dapat mengetahui pilihan kos yang ada.*
- **US01-AC1 (Data Tersedia)**: Given pengguna membuka aplikasi, When daftar kos berhasil dimuat dari Supabase, Then aplikasi menampilkan kartu kos berisi nama kos, area, harga per bulan, tipe penghuni, dan ikon fasilitas.
- **US01-AC2 (Data Kosong)**: Given database tidak memiliki data kos, When pengguna membuka aplikasi, Then aplikasi menampilkan pesan "Belum ada kos yang terdaftar".
- **US01-AC3 (Koneksi Gagal)**: Given koneksi internet terputus/gagal, When pengguna membuka daftar kos, Then aplikasi menampilkan pesan ramah "Gagal memuat data, periksa koneksi internet Anda" dan tombol coba lagi.
- **US01-AC4 (Akses Tanpa Login)**: Given pencari kos belum pernah melakukan login, When membuka aplikasi dan memilih kos, Then pencari tetap dapat melihat daftar kos dan membuka detail kos tanpa diminta login.

### US02: Melihat Detail Kos & Menyalin Kontak
*Sebagai Pencari Kos, saya ingin melihat rincian informasi kos dan menyalin nomor WhatsApp pemilik, agar saya bisa menghubungi pemilik kos langsung.*
- **US02-AC1 (Buka Detail)**: Given pencari memilih salah satu kartu kos, When kartu diketuk, Then aplikasi berpindah ke halaman detail menampilkan seluruh informasi lengkap kos (nama, alamat/area, deskripsi, harga, tipe, fasilitas, nomor WhatsApp).
- **US02-AC2 (Salin Kontak)**: Given pencari berada di halaman detail kos, When pencari mengetuk teks/tombol salin pada nomor WhatsApp pemilik, Then nomor tersalin ke clipboard sistem dan muncul notifikasi (SnackBar) "Nomor WhatsApp berhasil disalin".

### US03: Pencarian dan Penyaringan Kos
*Sebagai Pencari Kos, saya ingin mencari kos berdasarkan kata kunci serta memfilter berdasarkan harga maksimal dan fasilitas, agar saya cepat menemukan kos yang sesuai anggaran dan kebutuhan.*
- **US03-AC1 (Pencarian Kata Kunci Case-Insensitive)**: Given pengguna mengetik "singaraja" atau "Singaraja" di kolom pencarian, When sistem memproses pencarian, Then hasil yang muncul mencakup kos dengan kata tersebut pada nama kos atau area.
- **US03-AC2 (Filter Harga Maksimal)**: Given pengguna menentukan filter harga maksimal Rp 1.500.000, When filter diterapkan, Then hanya kos dengan harga <= Rp 1.500.000 yang ditampilkan.
- **US03-AC3 (Filter Fasilitas)**: Given pengguna mencentang filter "WiFi" dan "AC", When filter diterapkan, Then hanya kos yang memiliki minimal kedua fasilitas tersebut yang ditampilkan.
- **US03-AC4 (Hasil Filter Kosong)**: Given kombinasi pencarian/filter tidak cocok dengan kos mana pun, When filter diproses, Then aplikasi menampilkan pesan "Tidak ada kos yang sesuai dengan kriteria pencarian".

### US04: Registrasi dan Login Pemilik Kos
*Sebagai Pemilik Kos, saya ingin mendaftar dan masuk menggunakan email dan password, agar saya memiliki hak untuk mengelola kos saya.*
- **US04-AC1 (Pendaftaran Berhasil)**: Given calon pemilik memasukkan email valid dan password (min. 6 karakter), When tombol daftar ditekan, Then akun terdaftar di Supabase Auth dan pemilik langsung masuk ke sistem.
- **US04-AC2 (Login Berhasil)**: Given pemilik memasukkan email dan password yang benar, When tombol login ditekan, Then autentikasi berhasil dan pemilik diarahkan ke dashboard pengelolaan kos miliknya.
- **US04-AC3 (Login Gagal)**: Given pemilik memasukkan email atau kata sandi yang salah, When tombol login ditekan, Then muncul pesan "Email atau kata sandi salah".
- **US04-AC4 (Logout)**: Given pemilik sedang login, When menekan tombol logout, Then sesi berakhir dan pengguna kembali ke daftar kos sebagai pencari.

### US05: Menambah Kos Baru
*Sebagai Pemilik Kos yang telah masuk, saya ingin menambahkan data kos baru, agar kos saya dapat dilihat oleh pencari.*
- **US05-AC1 (Input Valid)**: Given pemilik telah login dan mengisi formulir (nama, area, harga angka, tipe penghuni, checklist fasilitas, nomor WhatsApp), When formulir disimpan, Then data tersimpan ke tabel Supabase dengan `owner_id` pemilik dan muncul di daftar kos.
- **US05-AC2 (Validasi Form)**: Given pemilik mengosongkan nama kos atau memasukkan harga non-angka / <= 0, When tombol simpan ditekan, Then sistem menampilkan pesan validasi dan tidak mengirim request ke Supabase.

### US06: Mengubah Kos Milik Sendiri
*Sebagai Pemilik Kos, saya ingin mengubah informasi kos milik saya, agar informasi tetap akurat.*
- **US06-AC1 (Ubah Berhasil)**: Given pemilik login dan membuka kos miliknya, When pemilik mengubah harga/fasilitas dan menyimpan, Then data di Supabase terbarui.
- **US06-AC2 (Penolakan Ubah Kos Orang Lain via RLS)**: Given pengguna B mencoba memanggil fungsi/request update terhadap record kos milik pengguna A, When request dikirim ke Supabase, Then 0 baris terubah dan data tidak berubah.

### US07: Menghapus Kos Milik Sendiri
*Sebagai Pemilik Kos, saya ingin menghapus kos milik saya dengan konfirmasi terlebih dahulu, agar data yang sudah tidak beroperasi hilang secara permanen.*
- **US07-AC1 (Konfirmasi Sebelum Hapus)**: Given pemilik menekan tombol hapus pada kos miliknya, When aksi dipicu, Then muncul dialog konfirmasi "Apakah Anda yakin ingin menghapus kos ini secara permanen?".
- **US07-AC2 (Hard Delete Berhasil)**: Given pemilik menyetujui dialog konfirmasi, When proses hapus selesai, Then record kos terhapus permanen dari Supabase dan tidak lagi muncul di daftar kos.
- **US07-AC3 (Penolakan Hapus Kos Orang Lain via RLS)**: Given pengguna B mencoba menghapus data kos milik pengguna A, When request dikirim ke backend, Then backend menolak aksi penghapusan melalui policy RLS.

---

### [FITUR BONUS - SLICE 5] US08: Pengelolaan Ketersediaan Kamar
*Sebagai Pemilik Kos, saya ingin memperbarui jumlah kamar yang tersedia, agar pencari kos tahu apakah kos masih ada kamar kosong atau sudah penuh.*
- **US08-AC1 (Tampilan Kamar Tersedia)**: Given kos memiliki kamar tersedia > 0 (misal: 3), When pencari melihat kartu/detail kos, Then aplikasi menampilkan teks "Tersedia 3 kamar".
- **US08-AC2 (Tampilan Kos Penuh)**: Given kamar tersedia bernilai 0, When pencari melihat kartu/detail kos, Then aplikasi menampilkan badge/teks peringatan "Penuh".
- **US08-AC3 (Pembaruan Kamar oleh Pemilik)**: Given pemilik memperbarui jumlah kamar menjadi 0 atau angka baru, When disimpan, Then angka ketersediaan kamar pada halaman pencari langsung terbarui.

---

## 6. Daftar Ambiguitas & Catatan
- Seluruh butir ambiguitas awal telah terjawab dan disepakati pada sesi klarifikasi Prompt 2. Tidak ada ambiguitas fungsional yang tersisa untuk Versi 1.
