
echo "installing packages .."
sudo pacman -S git base-devel exa mesa vscode spotify-launcher stow helix intellij-idea-community-edition waybar hyprland hyprsunset rofi-wayland ghostty xdg-desktop-portal-hyprland hyprpolkitagent qt5-wayland qt6-wayland imv nwg-look yazi starship fd zsh fzf swaync sddm bat swww grim slurp unzip uwsm docker docker-compose btop openssh cland cmake ninja wl-clipboard

echo "applying configs .. "

cd $HOME
mkdir -p repo
cd repo
git clone https://github.com/samintejas/dots.git
cd dots
stow -t ~ git
stow -t ~ zsh
stow -t ~/.config/ config

echo "changing default shell to zsh .. "

cd $HOME
# root
sudo chsh -s /bin/zsh
# user
sudo chsh -s /usr/bin/zsh $USER


echo "installing paru .. "

cd $HOME
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

echo "installing additional packages from aur .. "
cd $HOME
paru -S zen-browser
paru -S ttf-jetbrains-mono-nerd
paru -S mycli

echo "next step 1 : download and install work git certificated"
echo "next step 2 : add git credentials for personal and work"
echo "next step 3 : setup systemd-boot to include windows if any"
echo "next step 4 : setup duelboot optimizations if any"

