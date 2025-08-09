# Sewkos App (Flutter Frontend)

Ini adalah aplikasi mobile cross-platform (Android, iOS) untuk mencari kos di Sumba. Aplikasi ini dibangun dengan Flutter dan terhubung ke Sewkos Backend API.

## Fitur Utama

-   **Pencarian & Filter:** Filter canggih berdasarkan harga, fasilitas, lokasi, dan jangkauan.
-   **Peta Interaktif:** Menampilkan lokasi kos di OpenStreetMap.
-   **Detail Kos:** Halaman detail dengan deskripsi, gambar, dan formulir ulasan.
-   **Autentikasi Pemilik:** Alur login dan pendaftaran yang aman untuk pemilik kos.
-   **Dashboard Pemilik:** Mengelola daftar kos, termasuk opsi edit dan hapus.

## Persyaratan Sistem

-   [Flutter SDK](https://flutter.dev/docs/get-started/install)
-   [Android Studio](https://developer.android.com/studio) atau [Visual Studio Code](https://code.visualstudio.com/)
-   Perangkat fisik atau emulator Android/iOS

## Panduan Instalasi

1.  **Clone repositori:**
    ```bash
    git clone [https://github.com/nanutechsolution/sewkos-mobile.git](https://github.com/nanutechsolution/sewkos-mobile.git)
    cd sewkos-app
    ```

2.  **Instal dependensi:**
    ```bash
    flutter pub get
    ```

3.  **Konfigurasi Android:**
    Buka `android/app/src/main/AndroidManifest.xml` dan pastikan izin serta kunci Google Maps API sudah dikonfigurasi.

4.  **Jalankan aplikasi:**
    Hubungkan perangkat Anda atau jalankan emulator, lalu jalankan aplikasi.
    ```bash
    flutter run
    ```

## Screenshot

(Tambahkan screenshot aplikasi Anda di sini)
