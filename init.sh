#!/usr/bin/env bash
set -euo pipefail

GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

log()  { echo -e "${GREEN}==>${RESET} $1"; }
warn() { echo -e "${YELLOW}==>${RESET} $1"; }

log "Installing reflector and updating mirrors..."
sudo pacman -S --needed --noconfirm reflector
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

log "Updating package databases..."
sudo pacman -Syu --noconfirm

log "Installing base packages..."
packages=(
    # essentials
    git stow base-devel

    # shell
    zsh starship

    # editor + cli tools
    neovim ripgrep fd fzf bat eza yazi

    # yazi previews (video / image / pdf)
    ffmpegthumbnailer ueberzugpp poppler

    # hyprland
    hyprland hyprsunset hyprlock uwsm
    xdg-desktop-portal-hyprland hyprpolkitagent
    qt5-wayland qt6-wayland

    # desktop widgets
    waybar swaync rofi-wayland swww

    # terminal
    ghostty

    # screenshot
    grim slurp swappy wl-clipboard

    # login manager
    greetd greetd-tuigreet

    # hardware
    mesa bluez bluez-utils

    # services
    openssh docker docker-compose

    # monitoring
    btop

    # runtimes
    go nvm

    # utilities
    unzip bind-tools

    # credentials
    gnome-keyring libsecret

    # gtk + image viewer
    nwg-look imv

    # misc
    tealdeer ruff spotify-launcher

    #font
    otf-geist-mono-nerd
)
sudo pacman -S --needed --noconfirm "${packages[@]}"

log "Setting up directories..."
mkdir -p "$HOME/repo/zen" "$HOME/lib" "$HOME/tmp"

log "Cloning public repos..."
pushd "$HOME/repo/zen" > /dev/null
[ ! -d "dots" ]       && git clone https://github.com/samintejas/dots.git
[ ! -d "wallpapers" ] && git clone https://github.com/samintejas/wallpapers.git
[ ! -d "scripts" ]    && git clone https://github.com/samintejas/scripts.git
popd > /dev/null

log "Configuring dotfiles with stow..."
pushd "$HOME/repo/zen/dots" > /dev/null
stow -t "$HOME" home || warn "stow failed"
popd > /dev/null

log "Changing shell to zsh..."
chsh -s /bin/zsh "$USER"

log "Copying scripts..."
for script in powerctl sshot sshot-shift; do
    sudo cp "$HOME/repo/zen/scripts/$script" /usr/bin/
done

if ! command -v paru &>/dev/null; then
    log "Installing paru..."
    pushd "$HOME/tmp" > /dev/null
    git clone https://aur.archlinux.org/paru.git
    pushd paru > /dev/null
    makepkg -si --noconfirm
    popd > /dev/null
    popd > /dev/null
else
    log "paru already installed."
fi

log "Installing AUR packages..."
paru -S --needed --noconfirm zen-browser

log "Enabling services..."
sudo systemctl enable greetd.service
sudo systemctl enable docker.service

log "Installing go tools..."
go install mvdan.cc/gofumpt@latest
go install golang.org/x/tools/cmd/goimports@latest

log "Done!"
