# Panduan Berkontribusi pada Sewkos App

Kami senang Anda tertarik untuk berkontribusi pada proyek Sewkos App! Panduan ini akan membantu Anda memulai, melaporkan masalah, dan mengirimkan perubahan kode.

## Kode Etik
Kami berkomitmen untuk menciptakan lingkungan yang ramah dan inklusif. Mohon bersikap sopan dan menghargai semua anggota komunitas.

## Memulai

### Prasyarat
Pastikan Anda telah menginstal prasyarat berikut:
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Android Studio](https://developer.android.com/studio) atau [Visual Studio Code](https://code.visualstudio.com/) dengan plugin Flutter.
- [sewkos-backend](https://github.com/username-anda/sewkos-backend) yang berjalan secara lokal.

### Panduan Setup
1.  **Clone repositori:**
    ```bash
    git clone [https://github.com/username-anda/sewkos-app.git](https://github.com/username-anda/sewkos-app.git)
    cd sewkos-app
    ```

2.  **Instal dependensi:**
    ```bash
    flutter pub get
    ```

3.  **Konfigurasi Native (Android):**
    Buka `android/app/src/main/AndroidManifest.xml` dan konfigurasikan kunci Google Maps API Anda di dalam tag `<application>`.
    ```xml
    <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY"/>
    ```

4.  **Jalankan aplikasi:**
    Hubungkan perangkat atau emulator, lalu jalankan aplikasi dari terminal.
    ```bash
    flutter run
    ```

## Melaporkan Bug atau Mengusulkan Fitur

Sebelum mengirimkan Pull Request, mohon laporkan bug atau usulkan fitur baru melalui [GitHub Issues](https://github.com/username-anda/sewkos-app/issues). Ini membantu kami melacak masalah dan mendiskusikan perubahan.

## Mengirimkan Perubahan (Pull Requests)

Ikuti langkah-langkah di bawah ini untuk mengirimkan perubahan kode Anda:

1.  **Fork** repositori ini ke akun GitHub Anda.
2.  **Clone** hasil fork Anda ke mesin lokal.
3.  **Buat branch baru** untuk fitur atau perbaikan Anda.
    ```bash
    git checkout -b fitur/nama-fitur-baru
    ```
4.  **Lakukan perubahan** pada kode.
5.  **Commit perubahan** Anda dengan pesan yang jelas.
    ```bash
    git commit -m "feat: Menambahkan fitur X"
    ```
6.  **Push** branch Anda ke repositori hasil fork Anda.
    ```bash
    git push origin fitur/nama-fitur-baru
    ```
7.  **Buka Pull Request** di halaman GitHub utama proyek ini. Mohon berikan deskripsi yang jelas tentang perubahan yang Anda lakukan.