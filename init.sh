#!/bin/sh

case "$(uname)" in
    Darwin)
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
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


# nano
curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh


# dotfiles
if [ -d ~/dotfiles ]; then
    stashed=$(git -C ~/dotfiles stash)
    git -C ~/dotfiles pull
    case "$stashed" in
        *"No local changes"*) ;;
        *) git -C ~/dotfiles stash pop ;;
    esac
else
    git clone https://github.com/Mokuichi147/dotfiles ~/dotfiles
fi
sh ~/dotfiles/dotfilelink.sh


# Python (uv)
if command -v uv >/dev/null 2>&1; then
    uv self update
else
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi


# Rust
if command -v rustup >/dev/null 2>&1; then
    rustup update
else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi