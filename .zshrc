# Python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# alias
alias ..='cd ..'
alias py='python'
alias hello='figlet Hello\ world!'
alias zshrc='nano ~/.zshrc'
alias f='find ~/.zsh_history -type f -print | xargs grep'
alias g='find / -executable -type f -name'

# OS
case ${OSTYPE} in
    darwin*)
    alias ls='ls -G'
    ;;
    linux*)
    alias ls='ls --color'
    alias i2c='sudo i2cdetect -y 1'
    ;;
esac

# host
git_color=69
dir_color=147
zsh_hostname=$(hostname|cut -f 1 -d '.')
case $zsh_hostname in
    Mokuichi147-MacBook)
    zsh_color=197
    git_color=092
    export LIBRARY_PATH="$LIBRARY_PATH:/usr/local/lib"
    export PATH="$HOME/.nodebrew/current/bin:$PATH"
    alias blender='/Applications/Blender.app/Contents/MacOS/Blender'
    ;;
    mokuichi147-thinkcentre)
    zsh_color=30
    ;;
    DESK-Pi)
    zsh_color=6
    ;;
    REI-W)
    zsh_color=23
    ;;
    REI-WK)
    zsh_color=169
    ;;
    DESKTOP*)
    zsh_color=99
    git_color=220
    export PATH="$HOME/Documents/swift-5.2.4-RELEASE-ubuntu20.04/usr/bin:$PATH"
    ;;
    *)
    zsh_color=27
    ;;
esac

# zsh log
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000
setopt hist_ignore_all_dups
setopt EXTENDED_HISTORY
setopt share_history

# zsh
setopt auto_cd
setopt correct

# git branch
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '[%b]'
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd() { vcs_info }
setopt prompt_subst

# prompt
zsh_clock='%B%F{$zsh_color}[%*]%f'
zsh_dir='%F{$dir_color}[%~]%f'

PROMPT='$zsh_clock%F{$git_color}${vcs_info_msg_0_}%f$zsh_dir
%F{$zsh_color}>%f%b '
