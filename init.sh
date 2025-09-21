#!/usr/bin/env bash
set -euo pipefail

GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

log() { echo -e "${GREEN}==>${RESET} $1"; }
warn() { echo -e "${YELLOW}==>${RESET} $1"; }

log "Updating package databases..."
sudo pacman -Syyu --noconfirm

log "Installing base packages..."
sudo pacman -S --needed --noconfirm \
    reflector git base-devel exa mesa spotify-launcher stow \
    intellij-idea-community-edition waybar hyprland hyprsunset hyprlock \
    rofi-wayland ghostty xdg-desktop-portal-hyprland hyprpolkitagent \
    qt5-wayland qt6-wayland imv nwg-look yazi starship fd zsh fzf \
    swaync sddm bat swww grim slurp unzip uwsm docker docker-compose \
    btop openssh wl-clipboard bluez bluez-utils bind nvim go nvm

log "Updating mirrors with reflector..."
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

log "Setting up directories..."
mkdir -p "$HOME/repo/zen" "$HOME/lib" "$HOME/tmp"

log "Cloning public repos..."
cd "$HOME/repo/zen"
[ ! -d "dots" ] && git clone https://github.com/samintejas/dots.git
[ ! -d "wallpapers" ] && git clone https://github.com/samintejas/wallpapers.git
[ ! -d "scripts" ] && git clone https://github.com/samintejas/scripts.git

log "Configuring dotfiles with stow..."
cd "$HOME/repo/zen/dots"
stow -t "$HOME" zsh || warn "zsh stow failed"
mkdir -p "$HOME/.config"
stow -t "$HOME/.config" config || warn "config stow failed"

warn "Skipping automatic root shell change. Run 'chsh -s /bin/zsh' manually if needed."
chsh -s /bin/zsh $USER

log "Copying scipts"
sudo cp $HOME/repo/zen/scripts/powerctl /usr/bin/
sudo cp $HOME/repo/zen/scripts/sshot /usr/bin/

if ! command -v paru &>/dev/null; then
    log "Installing paru .."
    cd "$HOME/tmp"
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
else
    log "paru already installed."
fi

log "Installing AUR packages..."
paru -S --needed --noconfirm zen-browser ttf-jetbrains-mono-nerd visual-studio-code-bin

log "Enabling SDDM..."
sudo systemctl enable sddm.service

log "Done!"
