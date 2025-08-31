

echo "installing packages .."
sudo pacman -S reflector git base-devel exa mesa vscode spotify-launcher stow intellij-idea-community-edition waybar hyprland hyprsunset rofi-wayland ghostty xdg-desktop-portal-hyprland hyprpolkitagent qt5-wayland qt6-wayland imv nwg-look yazi starship fd zsh fzf swaync sddm bat swww grim slurp unzip uwsm docker docker-compose btop openssh wl-clipboard bluez bluez-utils

echo "updating mirrors"
reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

echo "resyncing repo"
sudo pacman -Syy

echo "pulling configs .. "

cd $HOME
mkdir -p $HOME/tmp

cd tmp
mkdir -p repo
cd repo
git clone https://github.com/samintejas/dots.git
cd dots

echo "configuring shell"
stow -t ~ zsh

sudo chsh -s /bin/zsh
sudo chsh -s /usr/bin/zsh $USER

echo "creating config symlink"
mkdir -p ~./.config
stow -t ~/.config/ config

echo "installing paru .. "

cd $HOME/tmp/
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si


echo "installing additional packages from aur .. "
cd $HOME/tmp/
paru -S zen-browser
paru -S ttf-jetbrains-mono-nerd

# echo "next step 1 : download and install work git certificated"
# echo "next step 2 : add git credentials for personal and work"
echo "next step 3 : setup grub"
echo "next step 4 : setup duelboot optimizations if any"

