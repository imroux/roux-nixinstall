#!/usr/bin/env nix-shell
#!nix-shell -i bash -p gum git

set_variables() {
  choice_dotfiles=$(gum choose "Yes" "No" --header "Would you like to install rouxshell?")
  choice_wallpapers=$(gum choose "Yes" "No" --header "Would you like to install Roux Wallpapers?")
  choice_reboot=$(gum choose "Yes" "No" --header "Would you like to reboot after installation is complete?")
}

install_dotfiles() {
  case "$choice_dotfiles" in
  Yes)
    echo "→ Installing rouxshell..."

    cd /home/$USER || exit

    # Create user folders
    mkdir -p /home/$USER/Data
    mkdir -p /home/$USER/.local/{bin,share/{backgrounds,themes,icons}}
    mkdir -p /home/$USER/.config/{cava,gtk-3.0,gtk-4.0,zsh}

    case "$choice_wallpapers" in
    Yes)
      git clone --depth 1 --recurse-submodules https://github.com/imroux/rouxshell.git /home/$USER/.local/share/rouxshell
      ;;
    No)
      git clone --depth 1 https://github.com/imroux/rouxshell.git /home/$USER/.local/share/rouxshell
      ;;
    esac
    cd /home/$USER/.local/share/rouxshell || exit

    # Link user configs with root configs
    sudo mkdir -p /root/.config
    sudo ln -sfn /home/$USER/.local/share/rouxshell/.zshrc /root/.zshrc
    sudo ln -sfn /home/$USER/.local/share/rouxshell/.config/zsh /root/.config/zsh
    sudo ln -sfn /home/$USER/.local/share/rouxshell/.config/starship.toml /root/.config/starship.toml
    sudo ln -sfn /home/$USER/.local/share/rouxshell/.config/nvim /root/.config/nvim

    # Rebuild the configuration
    sudo rm /etc/nixos/configuration.nix
    sudo ln /home/$USER/.local/share/rouxshell/nix-config/configuration.nix /etc/nixos/
    sudo nixos-rebuild switch --impure

    # Update caches
    bat cache --build
    tldr --update

    # Setup wallpaper
    case "$choice_wallpapers" in
    Yes)
      matugen image /home/$USER/.local/share/backgrounds/resident-evil/resident-evil-9-requiem/requiem_2.jpg --source-color-index 0
      ;;
    esac

    return 0
    ;;
  No)
    echo "→ Skipping installation of rouxshell..."
    exit 1
    ;;
  esac
}

clear

cat <<"EOF"
 /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\
( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )
 > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <
 /\_/\  ____                    _   _ ___        ___           _        _ _   /\_/\
( o.o )|  _ \ ___  _   ___  __ | \ | |_ _|_  __ |_ _|_ __  ___| |_ __ _| | | ( o.o )
 > ^ < | |_) / _ \| | | \ \/ / |  \| || |\ \/ /  | || '_ \/ __| __/ _` | | |  > ^ <
 /\_/\ |  _ < (_) | |_| |>  <  | |\  || | >  <   | || | | \__ \ || (_| | | |  /\_/\
( o.o )|_| \_\___/ \__,_/_/\_\ |_| \_|___/_/\_\ |___|_| |_|___/\__\__,_|_|_| ( o.o )
 > ^ <                                                                        > ^ <
 /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\  /\_/\
( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )( o.o )
 > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <  > ^ <
EOF

# Set global variables
set_variables

# Install rouxshell
until install_dotfiles; do :; done

case "$choice_reboot" in
Yes)
  sudo reboot
  ;;
esac
