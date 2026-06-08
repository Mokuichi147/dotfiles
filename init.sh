#!/bin/sh

case "$(uname)" in
    Darwin)
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew update
    brew upgrade
    brew install git tmux zsh-autosuggestions
    ;;
    Linux)
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install -y zsh tmux git gcc g++ unzip zsh-autosuggestions
    chsh -s $(which zsh)
    ;;
esac

chsh -s $(which zsh)


# nano
curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh


# dotfiles
git clone https://github.com/Mokuichi147/dotfiles ~/dotfiles
sh ~/dotfiles/dotfilelink.sh


# Python (uv)
curl -LsSf https://astral.sh/uv/install.sh | sh


# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y