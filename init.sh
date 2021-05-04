#!/bin/sh

# hostname
read -p "Hostname: " hostname
read -sp "Password: " password
echo "$password" | sudo -S hostnamectl set-hostname "$hostname"


# zsh shell
echo "$password" | sudo -S apt install -y zsh
chsh -s $(which zsh)


# zshrc & tmux.conf
curl -sSf -o ~/dotfiles/.zshrc https://raw.githubusercontent.com/Mokuichi147/dotfiles/main/.zshrc
curl -sSf -o ~/dotfiles/.tmux.conf https://raw.githubusercontent.com/Mokuichi147/dotfiles/main/.tmux.conf
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf


# Python (Pyenv)
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
git clone https://github.com/pyenv/pyenv-update.git ~/.pyenv/plugins/pyenv-update


# Rust
curl https://sh.rustup.rs -sSf | sh
