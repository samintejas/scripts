#!/bin/bash

PACKAGES=(
  base-devel
  git
  vim
  zen-browser
  neofetch
  htop
  zsh
  curl
  wget
  stow
)

AUR_PACKAGES=(
  spotify
)


echo "Updating system..."
sudo pacman -Syu --noconfirm
echo "Installing official packages..."
sudo pacman -S --noconfirm "${PACKAGES[@]}"

echo "Installing Paru (AUR Helper)..."
if ! command -v paru &> /dev/null; then
  git clone https://aur.archlinux.org/paru.git
  cd paru
  makepkg -si --noconfirm
  cd ..
  rm -rf paru
fi


chsh -s $(which zsh)
echo "Setup complete! Rebooting is recommended."
