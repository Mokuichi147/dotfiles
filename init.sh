#!/bin/sh

sudo apt-get update
sudo apt-get upgrade

# zsh shell
sudo apt-get install -y zsh tmux git
chsh -s $(which zsh)


# dotfiles
git clone https://github.com/Mokuichi147/dotfiles ~/dotfiles
sh ~/dotfiles/dotfilelink.sh


# Python (Pyenv)
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
git clone https://github.com/pyenv/pyenv-update.git ~/.pyenv/plugins/pyenv-update


# Rust
curl https://sh.rustup.rs -sSf | sh