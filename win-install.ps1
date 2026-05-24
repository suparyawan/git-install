# Jalankan dengan PowerShell (Run as Administrator jika ingin install otomatis)

Clear-Host
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "   INSTALL GIT & GH CLI TOOLKIT   " -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Lokasi home directory user di Windows (C:\Users\NamaUser)
$USER_HOME = $env:USERPROFILE

# Penanda status untuk Resume di akhir script
$STATUS_GIT = "Belum diproses"
$STATUS_TIG = "Belum diproses"
$STATUS_CONFIG = "Belum diproses"
$STATUS_GH = "Belum diproses"
$STATUS_CREDENTIAL = "Belum dikonfigurasi"

# Cek apakah git sudah ada
function Check-Git {
    if (Get-Command git -ErrorAction SilentlyContinue) { return $true } else { return $false }
}

# Cek apakah tig sudah ada
function Check-Tig {
    if (Get-Command tig -ErrorAction SilentlyContinue) { return $true } else { return $false }
}

# Cek apakah gh sudah ada
function Check-Gh {
    if (Get-Command gh -ErrorAction SilentlyContinue) { return $true } else { return $false }
}

# Cek apakah user sudah login di gh cli
function Check-GhAuth {
    if (Check-Gh) {
        $authStatus = gh auth status 2>&1
        if ($authStatus -match "Logged in to") { return $true } else { return $false }
    }
    return $false
}

function Install-Git {
    if (Check-Git) {
        Write-Host "✅ Git sudah terinstall, dilewati..." -ForegroundColor Green
        $global:STATUS_GIT = "Sudah Terpasang (Dilewati)"
    } else {
        Write-Host "📦 Installing Git via Winget..." -ForegroundColor Yellow
        winget install --id Git.Git -e --source winget
        if (Check-Git) {
            Write-Host "✅ Git berhasil diinstall" -ForegroundColor Green
            $global:STATUS_GIT = "Sukses Terinstall"
        } else {
            Write-Host "❌ Gagal menginstall Git" -ForegroundColor Red
            $global:STATUS_GIT = "Gagal"
        }
    }

    # Integrasi Instalasi Tig via Winget
    if (Check-Tig) {
        Write-Host "✅ Tig sudah terinstall, dilewati..." -ForegroundColor Green
        $global:STATUS_TIG = "Sudah Terpasang (Dilewati)"
    } else {
        Write-Host "📦 Installing Tig (Terminal GUI for Git) via Winget..." -ForegroundColor Yellow
        winget install --id Git.Tig -e --source winget
        if (Check-Tig) {
            Write-Host "✅ Tig berhasil diinstall" -ForegroundColor Green
            $global:STATUS_TIG = "Sukses Terinstall"
        } else {
            Write-Host "⚠️  Tig gagal diinstall atau tidak didukung otomatis di arsitektur ini." -ForegroundColor Yellow
            $global:STATUS_TIG = "Lewat/Gagal"
        }
    }

    # Integrasi Pemindahan Gitconfig
    Configure-Gitconfig
    Sync-GhCredential
}

function Configure-Gitconfig {
    Write-Host "⚙️  Configuring .gitconfig..." -ForegroundColor Cyan
    
    $targetPath = Join-Path $USER_HOME ".gitconfig"

    if (Test-Path "gitconfig") {
        Copy-Item "gitconfig" -Destination $targetPath -Force
        Write-Host "✅ File gitconfig berhasil disalin ke $targetPath" -ForegroundColor Green
        $global:STATUS_CONFIG = "Sukses disinkronkan"
    } elseif (Test-Path ".gitconfig") {
        Copy-Item ".gitconfig" -Destination $targetPath -Force
        Write-Host "✅ File .gitconfig berhasil disalin ke $targetPath" -ForegroundColor Green
        $global:STATUS_CONFIG = "Sukses disinkronkan"
    } else {
        Write-Host "⚠️  Peringatan: File template 'gitconfig' tidak ditemukan." -ForegroundColor Yellow
        $global:STATUS_CONFIG = "Gagal (File template tidak ditemukan)"
    }
}

function Install-Gh {
    if (Check-Gh) {
        Write-Host "✅ GitHub CLI (gh) sudah terinstall, dilewati..." -ForegroundColor Green
        $global:STATUS_GH = "Sudah Terpasang (Dilewati)"
    } else {
        Write-Host "📦 Installing GitHub CLI via Winget..." -ForegroundColor Yellow
        winget install --id GitHub.cli -e --source winget
        
        if (Check-Gh) {
            Write-Host "✅ GitHub CLI berhasil diinstall" -ForegroundColor Green
            $global:STATUS_GH = "Sukses Terinstall"
        } else {
            Write-Host "❌ Gagal menginstall GitHub CLI" -ForegroundColor Red
            $global:STATUS_GH = "Gagal"
        }
    }

    Sync-GhCredential
}

function Sync-GhCredential {
    if (Check-Gh) {
        if (Check-GhAuth) {
            Write-Host "⚙️  Mengeksekusi 'gh auth setup-git' otomatis..." -ForegroundColor Cyan
            gh auth setup-git 2>$null
            $global:STATUS_CREDENTIAL = "⚡ Aktif (Otomatis terhubung via gh)"
        } else {
            $global:STATUS_CREDENTIAL = "⏳ Menunggu (Harus jalankan 'gh auth login' dulu)"
        }
    }
}

function Show-Resume {
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "         RESUME INSTALASI & KONFIGURASI           " -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  Status Eksekusi:"
    Write-Host "  • Git Engine          : $STATUS_GIT"
    Write-Host "  • Tig Terminal GUI    : $STATUS_TIG"
    Write-Host "  • GitHub CLI (gh)     : $STATUS_GH"
    Write-Host "  • .gitconfig Sync     : $STATUS_CONFIG"
    Write-Host "  • GH Credential Helper: $STATUS_CREDENTIAL"
    Write-Host "--------------------------------------------------"
    
    Write-Host "  Informasi Versi Sistem Aktif:"
    if (Check-Git) { Write-Host "  ℹ️  Git Version    : $(git --version)" } else { Write-Host "  ℹ️  Git Version    : Tidak terdeteksi" }
    if (Check-Tig) { Write-Host "  ℹ️  Tig Version    : $(tig --version | Select-Object -First 1)" }
    if (Check-Gh) { Write-Host "  ℹ️  GH CLI Version : $(gh --version | Select-Object -First 1)" }
    Write-Host "--------------------------------------------------"

    Write-Host "  Hasil Pembacaan Akun Git Akhir (~/.gitconfig):"
    if (Test-Path (Join-Path $USER_HOME ".gitconfig")) {
        $CONF_NAME = git config --global user.name
        $CONF_EMAIL = git config --global user.email
        $CONF_BRANCH = git config --global init.defaultBranch
        
        Write-Host "  👤 User Name      : $CONF_NAME"
        Write-Host "  📧 User Email     : $CONF_EMAIL"
        Write-Host "  🌿 Default Branch : $CONF_BRANCH"
        Write-Host "  🚀 Alias 'git lg' : Tersedia (Siap digunakan!)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  File ~/.gitconfig tidak ditemukan di system local." -ForegroundColor Yellow
    }
    Write-Host "--------------------------------------------------"
    
    if (Check-Gh) {
        if (-not (Check-GhAuth)) {
            Write-Host "  💡 TIPS LANJUTAN:" -ForegroundColor Yellow
            Write-Host "     Karena Anda belum login ke GitHub CLI, integrasi passwordless"
            Write-Host "     belum bisa diaktifkan secara otomatis. Silakan ketik:"
            Write-Host "     👉 gh auth login" -ForegroundColor Cyan
            Write-Host "     Setelah sukses login, sinkronisasikan manual sekali dengan:"
            Write-Host "     👉 gh auth setup-git" -ForegroundColor Cyan
        } else {
            Write-Host "  🎉 SINKRONISASI BERHASIL!" -ForegroundColor Green
            Write-Host "     Sistem mendeteksi Anda telah login di GitHub CLI."
            Write-Host "     Perintah 'gh auth setup-git' telah sukses dieksekusi."
            Write-Host "     Sekarang Anda bisa 'git push/pull' tanpa diminta password!"
        }
    }
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "             SELESAI / READY TO USE               " -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
}

# Loop Menu Utama
while ($true) {
    Write-Host ""
    Write-Host "Pilih menu:"
    Write-Host "1) Install Git, Tig & Sync Config"
    Write-Host "2) Install GitHub CLI (gh)"
    Write-Host "3) Install Semua"
    Write-Host "4) Keluar"
    Write-Host ""

    $pilihan = Read-Host "Masukkan pilihan [1-4]"

    switch ($pilihan) {
        "1" {
            Install-Git
            Show-Resume
            exit
        }
        "2" {
            Install-Gh
            Show-Resume
            exit
        }
        "3" {
            Install-Git
            Install-Gh
            Show-Resume
            exit
        }
        "4" {
            Write-Host "👋 Keluar..."
            exit
        }
        Default {
            Write-Host "❌ Pilihan tidak valid" -ForegroundColor Red
        }
    }
}
