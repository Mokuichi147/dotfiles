#!/bin/sh

# hostname
printf "hostname:"
read hostname
hostnamectl set-hostname "$hostname"

# zsh shell
sudo -S apt install -y zsh

chsh -s $(which zsh)

# Python (Pyenv)
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
git clone https://github.com/pyenv/pyenv-update.git ~/.pyenv/plugins/pyenv-update

# Rust
curl https://sh.rustup.rs -sSf | sh
