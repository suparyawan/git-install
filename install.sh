#!/bin/bash

clear
echo "=================================="
echo "   INSTALL GIT & GH CLI TOOLKIT   "
echo "=================================="
echo ""

# cek apakah git sudah ada
check_git() {
    if command -v git &> /dev/null; then
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
    else
        echo "📦 Installing Git..."
        sudo apt update
        sudo apt install -y git
        echo "✅ Git berhasil diinstall"
    fi
}

install_gh() {
    if check_gh; then
        echo "✅ GitHub CLI (gh) sudah terinstall, dilewati..."
    else
        echo "📦 Installing GitHub CLI..."

        # install dependency
        sudo apt update
        sudo apt install -y curl

        # add repo GH CLI
        type -p curl >/dev/null || sudo apt install curl -y
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
            sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
            sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

        sudo apt update
        sudo apt install -y gh

        echo "✅ GitHub CLI berhasil diinstall"
    fi
}

while true; do
    echo ""
    echo "Pilih menu:"
    echo "1) Install Git"
    echo "2) Install GitHub CLI (gh)"
    echo "3) Install Semua"
    echo "4) Keluar"
    echo ""

    read -p "Masukkan pilihan [1-4]: " pilihan

    case $pilihan in
        1)
            install_git
            ;;
        2)
            install_gh
            ;;
        3)
            install_git
            install_gh
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
