# Jalankan dengan PowerShell (Run as Administrator)

Clear-Host
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "   INSTALL GIT & GH CLI TOOLKIT   " -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$USER_HOME = $env:USERPROFILE

# Penanda status untuk Resume
$STATUS_GIT = "Belum diproses"
$STATUS_TIG = "Belum diproses"
$STATUS_CONFIG = "Belum diproses"
$STATUS_GH = "Belum diproses"
$STATUS_CREDENTIAL = "Belum dikonfigurasi"

function Check-Git {
    if (Get-Command git -ErrorAction SilentlyContinue) { return $true } else { return $false }
}

function Check-Tig {
    if (Get-Command tig -ErrorAction SilentlyContinue) { return $true } else { return $false }
}

function Check-Gh {
    if (Get-Command gh -ErrorAction SilentlyContinue) { return $true } else { return $false }
}

function Check-GhAuth {
    if (Check-Gh) {
        # Menggunakan redirect 2>&1 untuk menangkap data tanpa memicu teks merah di layar
        $authStatus = gh auth status 2>&1 | Out-String
        if ($authStatus -match "Logged in to") { return $true } else { return $false }
    }
    return $false
}

function Configure-Gitconfig {
    Write-Host "Configuring .gitconfig..." -ForegroundColor Cyan
    
    $targetPath = Join-Path $USER_HOME ".gitconfig"
    $sourcePathRaw = Join-Path $PSScriptRoot "gitconfig"
    $sourcePathDot = Join-Path $PSScriptRoot ".gitconfig"

    if (Test-Path $sourcePathRaw) {
        Copy-Item $sourcePathRaw -Destination $targetPath -Force
        Write-Host "File gitconfig berhasil disalin ke $targetPath" -ForegroundColor Green
        $global:STATUS_CONFIG = "Sukses disinkronkan"
    } elseif (Test-Path $sourcePathDot) {
        Copy-Item $sourcePathDot -Destination $targetPath -Force
        Write-Host "File .gitconfig berhasil disalin ke $targetPath" -ForegroundColor Green
        $global:STATUS_CONFIG = "Sukses disinkronkan"
    } else {
        Write-Host "Peringatan: File template 'gitconfig' tidak ditemukan di folder script." -ForegroundColor Yellow
        $global:STATUS_CONFIG = "Gagal (File tidak ditemukan)"
    }
}

function Sync-GhCredential {
    if (Check-Gh) {
        if (Check-GhAuth) {
            Write-Host "Mengeksekusi 'gh auth setup-git' otomatis..." -ForegroundColor Cyan
            gh auth setup-git 2>$null
            $global:STATUS_CREDENTIAL = "Aktif (Otomatis terhubung via gh)"
        } else {
            $global:STATUS_CREDENTIAL = "Menunggu (Harus jalankan 'gh auth login' dulu)"
        }
    }
}

function Install-Git {
    if (Check-Git) {
        Write-Host "Git sudah terinstall, dilewati..." -ForegroundColor Green
        $global:STATUS_GIT = "Sudah Terpasang (Dilewati)"
    } else {
        Write-Host "Installing Git via Winget..." -ForegroundColor Yellow
        winget install --id Git.Git -e --source winget
        if (Check-Git) {
            Write-Host "Git berhasil diinstall" -ForegroundColor Green
            $global:STATUS_GIT = "Sukses Terinstall"
        } else {
            Write-Host "Gagal menginstall Git" -ForegroundColor Red
            $global:STATUS_GIT = "Gagal"
        }
    }

    if (Check-Tig) {
        Write-Host "Tig sudah terinstall, dilewati..." -ForegroundColor Green
        $global:STATUS_TIG = "Sudah Terpasang (Dilewati)"
    } else {
        Write-Host "Installing Tig via Winget..." -ForegroundColor Yellow
        winget install --id Git.Tig -e --source winget
        if (Check-Tig) {
            Write-Host "Tig berhasil diinstall" -ForegroundColor Green
            $global:STATUS_TIG = "Sukses Terinstall"
        } else {
            Write-Host "Tig dilewati atau tidak tersedia otomatis" -ForegroundColor Yellow
            $global:STATUS_TIG = "Dilewati"
        }
    }

    Configure-Gitconfig
    Sync-GhCredential
}

function Install-Gh {
    if (Check-Gh) {
        Write-Host "GitHub CLI (gh) sudah terinstall, dilewati..." -ForegroundColor Green
        $global:STATUS_GH = "Sudah Terpasang (Dilewati)"
    } else {
        Write-Host "Installing GitHub CLI via Winget..." -ForegroundColor Yellow
        winget install --id GitHub.cli -e --source winget
        if (Check-Gh) {
            Write-Host "GitHub CLI berhasil diinstall" -ForegroundColor Green
            $global:STATUS_GH = "Sukses Terinstall"
        } else {
            Write-Host "Gagal menginstall GitHub CLI" -ForegroundColor Red
            $global:STATUS_GH = "Gagal"
        }
    }

    Sync-GhCredential
}

function Show-Resume {
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "         RESUME INSTALASI AND KONFIGURASI         " -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  Status Eksekusi:"
    Write-Host "  * Git Engine          : $STATUS_GIT"
    Write-Host "  * Tig Terminal GUI    : $STATUS_TIG"
    Write-Host "  * GitHub CLI (gh)     : $STATUS_GH"
    Write-Host "  * .gitconfig Sync     : $STATUS_CONFIG"
    Write-Host "  * GH Credential Helper: $STATUS_CREDENTIAL"
    Write-Host "--------------------------------------------------"
    
    Write-Host "  Informasi Versi Sistem Aktif:"
    if (Check-Git) { Write-Host "  Git Version    : $(git --version)" } else { Write-Host "  Git Version    : Tidak terdeteksi" }
    if (Check-Tig) { Write-Host "  Tig Version    : $(tig --version | Select-Object -First 1)" }
    if (Check-Gh) { Write-Host "  GH CLI Version : $(gh --version | Select-Object -First 1)" }
    Write-Host "--------------------------------------------------"

    Write-Host "  Hasil Pembacaan Akun Git Akhir (~/.gitconfig):"
    if (Test-Path (Join-Path $USER_HOME ".gitconfig")) {
        $CONF_NAME = git config --global user.name
        $CONF_EMAIL = git config --global user.email
        $CONF_BRANCH = git config --global init.defaultBranch
        
        Write-Host "  User Name      : $CONF_NAME"
        Write-Host "  User Email     : $CONF_EMAIL"
        Write-Host "  Default Branch : $CONF_BRANCH"
        Write-Host "  Alias 'git lg' : Tersedia" -ForegroundColor Green
    } else {
        Write-Host "  File ~/.gitconfig tidak ditemukan di lokal." -ForegroundColor Yellow
    }
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "             SELESAI / READY TO USE               " -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
}

# Loop Menu
while ($true) {
    Write-Host "Pilih menu:"
    Write-Host "1) Install Git, Tig and Sync Config"
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
            Write-Host "Keluar..."
            exit
        }
        Default {
            Write-Host "Pilihan tidak valid" -ForegroundColor Red
        }
    }
}