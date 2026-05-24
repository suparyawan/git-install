# Git & GitHub CLI Automation Toolkit Guide

Dokumentasi ini berisi panduan lengkap untuk menginstalasi, mengonfigurasi, dan mengoperasikan *Toolkit Git* di lingkungan **Linux (Orange Pi)** maupun **Windows (PowerShell)** berdasarkan hasil kustomisasi dan standardisasi automasi DevOps Anda.

---

## 1. Alur Instalasi Toolkit (`gh` -> `git` -> `tig`)

Untuk memastikan integrasi *passwordless* dan autentikasi berjalan lancar tanpa kendala kredensial, urutan instalasi diatur agar GitHub CLI (`gh`) dikonfigurasi bersamaan dengan pemasangan Git Engine.

### 🐧 Opsi A: Menggunakan Linux Bash (`install.sh`)
Script automasi di Linux menggunakan `apt` sebagai pengelola paket dan secara otomatis menambahkan repositori resmi dari GitHub.

```bash
# Jalankan script otomasi Anda
./install.sh
```

**Langkah Manual di Balik Layar:**
1. **GitHub CLI (`gh`):** Mengunduh keyring GPG resmi dan mendaftarkan sumber repositori `cli.github.com` ke `sources.list.d`.
2. **Git Engine:** Memasang versi Git stabil terbaru melalui `apt install git`.
3. **Tig (Terminal GUI):** Memasang antarmuka grafis berbasis teks (TUI) melalui `apt install tig` untuk visualisasi branch yang interaktif.

### 🪟 Opsi B: Menggunakan Windows PowerShell (`win-install.ps1`)
Untuk lingkungan Windows, script memanfaatkan **Winget** (Windows Package Manager) bawaan Microsoft sehingga instalasi bersifat bersih dan terpusat.

```powershell
# Jalankan di PowerShell dengan Hak Akses Administrator
powershell -ExecutionPolicy Bypass -File .\win-install.ps1
```

**Fitur Proteksi yang Diterapkan:**
* Menggunakan pengalihan stream `2>&1` pada fungsi `Check-GhAuth` untuk membungkam pesan *Stderr* teks merah bawaan PowerShell agar visualisasi resume tetap bersih.
* Menggunakan `$PSScriptRoot` untuk mengunci folder aktif secara absolut, menjamin file template konfigurasi pasti ditemukan.

---

## 2. Sinkronisasi Git Config & Kredensial Otomatis

### ⚙️ Manajemen `.gitconfig`
Script secara otomatis memindahkan template file `gitconfig` ke folder home utama user:
* **Linux:** `$HOME/.gitconfig`
* **Windows:** `$env:USERPROFILE\.gitconfig` (C:\Users\NamaUser\.gitconfig)

Isi konfigurasi global kustom Anda mencakup optimasi *Line Ending* (`autocrlf = true` untuk Windows), pengaturan default branch ke `main`, serta alias esensial:
```ini
[alias]
    lg = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all
    st = status
    cm = commit -m
    br = branch
    ft = !git fetch && git status
```

### ⚡ Jembatan Kredensial Otomatis (*Passwordless*)
Guna mengatasi kendala klasik Git yang terus-menerus meminta username dan password saat melakukan `git push` via HTTPS, script menguji status autentikasi `gh auth status`. 

Jika Anda telah login, script otomatis mengeksekusi perintah penjembatan:
```bash
gh auth setup-git
```
Perintah ini menyuntikkan konfigurasi *Credential Helper* khusus ke dalam `.gitconfig` Anda:
```ini
[credential "https://github.com"]
    helper = !/usr/bin/gh auth git-credential
```
*Hasilnya, Git lokal akan meminjam token aman milik GitHub CLI secara mulus di balik layar.*

---

## 3. Git Command Cheat Sheet (Operasional Instan)

Berikut adalah daftar perintah harian komprehensif yang telah diperbarui, termasuk perintah dasar (basic setup) hingga perintah advanced terintegrasi alias kustom Anda:

| Kategori | Perintah Asli / Alias | Fungsi / Kegunaan |
| :--- | :--- | :--- |
| **Identitas** | `git config --global user.email "email@anda.com"` | Mengatur email identitas penulis secara global di sistem local. |
| **Identitas** | `git config --global user.name "hendra"` | Mengatur nama identitas penulis secara global di sistem local. |
| **Inisialisasi** | `git init` | Membuat/menginisialisasi repositori Git baru di dalam folder lokal saat ini. |
| **Staging** | `git add .` | Melacak dan memasukkan seluruh perubahan file baru/modifikasi ke dalam *Staging Area*. |
| **Status** | `git status` (atau **`git st`**) | Memeriksa kondisi folder kerja, file berstatus *staged*, *unstaged*, atau *untracked*. |
| **Status** | `git fetch && git status` (atau **`git ft`**) | **Sangat Direkomendasikan!** Mengintip perubahan di GitHub dulu baru menampilkan status kejujuran repositori local. |
| **Commit** | `git commit -m "keterangan"` (atau **`git cm "keterangan"`**) | Mengunci draf di staging area menjadi satu gerbong commit baru dengan pesan catatan. |
| **Remote** | `git remote -v` | Menampilkan daftar alamat URL repositori server (*remote remote*) yang terhubung. |
| **Remote** | `git remote add <nama> <url>` | Menghubungkan repositori lokal saat ini dengan repositori server kosong di GitHub. |
| **Push & Pull** | `git push origin main` | Mengunggah gerbong commit lokal Anda ke cabang branch server di GitHub. |
| **Push & Pull** | `git pull origin main` | Menarik sekaligus menyatukan (*merge*) kode terbaru dari GitHub ke folder lokal Anda. |
| **Riwayat** | `git log` | Menampilkan riwayat urutan commit resmi pada branch yang sedang aktif saat ini. |
| **Riwayat** | `git log --graph ...` (atau **`git lg`**) | Menampilkan pohon sejarah commit kustom, super indah, rapi, terstruktur, dan berwarna. |
| **Riwayat** | `git reflog` | **Kotak Hitam Lokal!** Mencatat setiap histori pergerakan pointer HEAD (pindah branch, reset, amandemen). |
| **Pembatalan** | `git revert -n <hash>..HEAD` | **Advanced Revert!** Membuat draf pembatalan gabungan (squash) untuk rentang commit tertentu tanpa merusak riwayat log lama. |

---

## 4. Pemahaman Arsitektur & Sinkronisasi Git

### 🕒 Penanganan Zona Waktu Berbeda (Orange Pi `+0` vs Windows `+8`)
Git memiliki tingkat ketahanan tinggi terhadap perbedaan waktu antarperangkat. Git **tidak akan mengalami tumpang tindih atau rusak** meskipun jam sistem antar-node tidak sinkron.
* **Mekanisme Intern**: Git mengonversi setiap waktu lokal ke format **Unix Epoch Timestamp** (hitungan detik absolut dunia sejak 1 Januari 1970 UTC).
* **Urutan Silsilah**: Pengurutan riwayat kode murni didasarkan atas hubungan silsilah **Parent Hash (Orang Tua - Anak)**, bukan berdasarkan jam dinding kalender. 
* *Tips DevOps:* Agar pembacaan analitik log container server tidak membingungkan, samakan zona waktu Orange Pi ke WITA dengan perintah: `sudo timedatectl set-timezone Asia/Makassar`.

### 🔄 Memahami Perbedaan Logika Git:

#### A. Revert (`git revert`)
Cara paling aman untuk membatalkan perubahan yang **sudah telanjur di-push ke GitHub** karena tidak menghapus sejarah lama, melainkan membuat commit baru di depan yang isinya merupakan kebalikan (*inverse*) dari kode lama.

Secara khusus, terdapat teknik tingkat lanjut (*advanced*) menggunakan flag `-n` (atau `--no-commit`) dikombinasikan dengan *range commit* (`..HEAD`):

```bash
git revert -n <hash_commit_awal>..HEAD
```

##### 1. Cara Kerja & Logika Perintah:
* **`-n` atau `--no-commit`**: Flag ini menahan Git agar **tidak langsung membuat commit otomatis** untuk setiap file yang dibatalkan. Perubahan kebalikan akan dimasukkan dan dikumpulkan terlebih dahulu ke dalam *Staging Area* (kondisi *staged*).
* **`<hash_commit_awal>..HEAD`**: Ini adalah *range* (jarak rentang). Perintah ini memberi tahu Git: *"Ambil semua commit yang terjadi setelah `<hash_commit_awal>` sampai dengan commit terakhir saat ini (`HEAD`), lalu balikkan semua efek kodenya."*
* **Keuntungan DevOps**: Jika Anda memiliki beberapa commit beruntun yang merusak sistem, perintah ini tidak akan mengotorilogi sejarah Git Anda dengan banyak commit revert baru. Git akan **menyatukan (*squash*) seluruh pembatalan tersebut ke dalam 1 draft perubahan saja** di *working directory* Anda, sehingga Anda bisa memeriksanya dulu sebelum melakukan satu commit penyelamatan yang bersih.

##### 2. Skenario & Contoh Kasus Riil:
Bayangkan riwayat `git lg` Anda terlihat seperti ini:
* `C34a1f` (HEAD) - Memperbaiki layout tombol payment *(Ternyata bug fatal!)*
* `B78e2d` - Menambahkan integrasi webhook gateway baru *(Ternyata meledak/error!)*
* `A12b9c` - Mengubah skema validasi database API *(Ternyata salah desain!)*
* `95f3e2` - **[Kondisi Stabil]** Fitur login basic bekerja dengan mulus.

Anda ingin membatalkan efek dari commit `A12b9c`, `B78e2d`, dan `C34a1f` sekaligus, lalu mengembalikan kode ke kondisi stabil terakhir seperti pada commit `95f3e2`. Anda cukup mengetikkan:
```bash
git revert -n 95f3e2..HEAD
```
Setelah dieksekusi, Git menghitung semua modifikasi terbalik dari ketiga commit tersebut, menaruh seluruh drafnya langsung di *Staging Area* (status *modified* siap commit) tanpa menambah log baru. Anda bisa melakukan uji coba kodenya terlebih dahulu, lalu menguncinya menjadi satu commit penyelamatan yang bersih:
```bash
git commit -m "revert: membatalkan rangkaian fitur payment gateway yang rusak dari commit 95f3e2 hingga HEAD"
```

#### B. Log vs Reflog
* **`git log`**: Buku sejarah resmi proyek. Hanya menampilkan jejak commit yang masih hidup di dalam branch aktif saat ini. Jika ada branch yang dihapus atau dicabut, jejaknya hilang dari sini.
* **`git reflog`**: Kotak hitam (*Black Box*) pesawat terminal Anda. Mencatat **setiap pergerakan ujung pointer HEAD** secara lokal di komputer tersebut (kapan Anda pindah branch, kapan Anda commit, melakukan amandemen, bahkan commit yang terbuang karena amandemen/reset tetap tercatat di sini selama 90 hari). Penyelamat utama saat kehilangan kode.

#### C. Detached HEAD Branch
Kondisi di mana Anda berpindah tempat (*checkout*) langsung menuju ke sebuah kode **Hash Commit tertentu**, dan bukan menuju ke nama sebuah branch resmi.
* **Dampaknya:** Pointer HEAD lepas dari jalur rel branch. Anda diperbolehkan melihat kode masa lalu atau bereksperimen mengetik kode baru di sana. Namun ingat, jika Anda membuat commit baru dalam kondisi *Detached HEAD*, commit tersebut tidak memiliki ikatan branch dan akan **terbengkalai/hilang** begitu Anda melakukan checkout kembali ke branch `main`. 
* *Solusi Menyelamatkannya:* Jika eksperimen di kondisi detached sukses, segera ikat menjadi branch resmi dengan mengetik: `git checkout -b nama-branch-baru`.