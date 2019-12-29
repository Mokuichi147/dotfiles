# Python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

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
zsh_hostname=$(hostname|cut -f 1 -d '.')
case $zsh_hostname in
    MacBookKF)
    zsh_color=197
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
    *)
    zsh_color=031
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
zstyle ':vcs_info:*' formats '{%b}'
zstyle ':vcs_info:*' actionformats '{%b|%a}'
precmd() { vcs_info }
setopt prompt_subst

# prompt
zsh_clock='%B%K{$zsh_color}%F{255}{%*}%f%k'
zsh_dir='%K{208}%F{255}{%~}%f%k'

PROMPT='$zsh_clock%K{092}%F{255}${vcs_info_msg_0_}%f%k$zsh_dir
%F{$zsh_color}>%f%b '
