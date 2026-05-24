#!/bin/bash

clear
echo "=================================="
echo "   INSTALL GIT & GH CLI TOOLKIT   "
echo "=================================="
echo ""

# Lokasi home directory user saat ini
USER_HOME=$HOME

# Penanda status untuk Resume di akhir script
STATUS_GIT="Belum diproses"
STATUS_TIG="Belum diproses"
STATUS_CONFIG="Belum diproses"
STATUS_GH="Belum diproses"

# cek apakah git sudah ada
check_git() {
    if command -v git &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# cek apakah tig sudah ada
check_tig() {
    if command -v tig &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# cek apakah gh sudah ada
check_gh() {
    if command -v gh &> /dev/null; then
        return 0
    else
        return 1
    fi
}

install_git() {
    if check_git; then
        echo "✅ Git sudah terinstall, dilewati..."
        STATUS_GIT="Sudah Terpasang (Dilewati)"
    else
        echo "📦 Installing Git..."
        sudo apt update && sudo apt install -y git
        if check_git; then
            echo "✅ Git berhasil diinstall"
            STATUS_GIT="Sukses Terinstall"
        else
            echo "❌ Gagal menginstall Git"
            STATUS_GIT="Gagal"
        fi
    fi

    # Integrasi Instalasi Tig
    if check_tig; then
        echo "✅ Tig sudah terinstall, dilewati..."
        STATUS_TIG="Sudah Terpasang (Dilewati)"
    else
        echo "📦 Installing Tig (Terminal GUI for Git)..."
        sudo apt update && sudo apt install -y tig
        if check_tig; then
            echo "✅ Tig berhasil diinstall"
            STATUS_TIG="Sukses Terinstall"
        fi
    fi

    # Integrasi Pemindahan Gitconfig
    configure_gitconfig
}

configure_gitconfig() {
    echo "⚙️  Configuring .gitconfig..."
    
    if [ -f "gitconfig" ]; then
        cp gitconfig "$USER_HOME/.gitconfig"
        echo "✅ File gitconfig berhasil disalin ke $USER_HOME/.gitconfig"
        STATUS_CONFIG="Sukses disinkronkan"
    elif [ -f ".gitconfig" ]; then
        cp .gitconfig "$USER_HOME/.gitconfig"
        echo "✅ File .gitconfig berhasil disalin ke $USER_HOME/.gitconfig"
        STATUS_CONFIG="Sukses disinkronkan"
    else
        echo "⚠️  Peringatan: File template 'gitconfig' tidak ditemukan."
        STATUS_CONFIG="Gagal (File template tidak ditemukan)"
    fi
}

install_gh() {
    if check_gh; then
        echo "✅ GitHub CLI (gh) sudah terinstall, dilewati..."
        STATUS_GH="Sudah Terpasang (Dilewati)"
    else
        echo "📦 Installing GitHub CLI..."
        sudo apt update && sudo apt install -y curl

        type -p curl >/dev/null || sudo apt install curl -y
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
            sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null

        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
            sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

        sudo apt update && sudo apt install -y gh
        
        if check_gh; then
            echo "✅ GitHub CLI berhasil diinstall"
            STATUS_GH="Sukses Terinstall"
        else
            echo "❌ Gagal menginstall GitHub CLI"
            STATUS_GH="Gagal"
        fi
    fi
}

show_resume() {
    echo ""
    echo "=================================================="
    echo "         RESUME INSTALASI & KONFIGURASI           "
    echo "=================================================="
    echo "  Status Eksekusi:"
    echo "  • Git Engine      : $STATUS_GIT"
    echo "  • Tig Terminal GUI: $STATUS_TIG"
    echo "  • GitHub CLI (gh) : $STATUS_GH"
    echo "  • .gitconfig Sync : $STATUS_CONFIG"
    echo "--------------------------------------------------"
    
    echo "  Informasi Versi Sistem Aktif:"
    if check_git; then
        echo "  ℹ️  Git Version    : $(git --version)"
    else
        echo "  ℹ️  Git Version    : Tidak terdeteksi"
    fi

    if check_tig; then
        echo "  ℹ️  Tig Version    : $(tig --version | head -n 1)"
    fi

    if check_gh; then
        echo "  ℹ️  GH CLI Version : $(gh --version | head -n 1)"
    fi
    echo "--------------------------------------------------"

    echo "  Hasil Pembacaan Akun Git Akhir (~/.gitconfig):"
    if [ -f "$USER_HOME/.gitconfig" ]; then
        CONF_NAME=$(git config --global user.name)
        CONF_EMAIL=$(git config --global user.email)
        CONF_BRANCH=$(git config --global init.defaultBranch)
        
        echo "  👤 User Name      : ${CONF_NAME:-'(Belum diatur)'}"
        echo "  📧 User Email     : ${CONF_EMAIL:-'(Belum diatur)'}"
        echo "  🌿 Default Branch : ${CONF_BRANCH:-'main (bawaan)'}"
        echo "  🚀 Alias 'git lg' : Tersedia (Siap digunakan!)"
    else
        echo "  ⚠️  File ~/.gitconfig tidak ditemukan di system local."
    fi
    echo "=================================================="
    echo "             SELESAI / READY TO USE               "
    echo "=================================================="
    echo ""
}

while true; do
    echo ""
    echo "Pilih menu:"
    echo "1) Install Git, Tig & Sync Config"
    echo "2) Install GitHub CLI (gh)"
    echo "3) Install Semua"
    echo "4) Keluar"
    echo ""

    read -p "Masukkan pilihan [1-4]: " pilihan

    case $pilihan in
        1)
            install_git
            show_resume
            exit 0
            ;;
        2)
            install_gh
            show_resume
            exit 0
            ;;
        3)
            install_git
            install_gh
            show_resume
            exit 0
            ;;
        4)
            echo "👋 Keluar..."
            exit 0
            ;;
        *)
            echo "❌ Pilihan tidak valid"
            ;;
    esac
done
