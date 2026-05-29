#!/bin/sh

sudo apt-get update
sudo apt-get upgrade


# zsh etc...
sudo apt-get install -y zsh tmux git gcc g++ unzip
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