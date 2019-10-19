export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

alias ls='ls --color'
alias ..='cd ..'
alias py='python'
alias hello='figlet Hello\ world!'
alias zsh='nano ~/.zshrc'
alias f='find ~/.zsh_history -type f -print | xargs grep'
alias g='find / -executable -type f -name'

case ${OSTYPE} in
    darwin*)
    ;;
    linux*)
    alias i2c='sudo i2cdetect -y 1'
    ;;
esac

export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000
setopt hist_ignore_all_dups
setopt EXTENDED_HISTORY
setopt share_history

setopt auto_cd
setopt correct

autoload -Uz vcs_info
zstyle ':vcs_info:*' formats ' %b '
zstyle ':vcs_info:*' actionformats ' %b|%a '
precmd() { vcs_info }
setopt prompt_subst

source ~/.zshrc.mine
