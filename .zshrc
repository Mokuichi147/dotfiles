# Python (uv)
export PATH="$HOME/.local/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# C#
export PATH="/usr/local/share/dotnet:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"
export DOTNET_CLI_TELEMETRY_OPTOUT="true"
export DOTNET_INTERACTIVE_CLI_TELEMETRY_OPTOUT="true"

# Node
export PATH="$HOME/.nodebrew/current/bin:$PATH"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# openssl
#export OPENSSL_DIR="$HOME/openssl-1.1.1q"
export OPENSSL_DIR="/usr/local"
export CMAKE_CXX_COMPILER="/usr/bin/cmake"

# Wasmer
export WASMER_DIR="$HOME/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"

# alias
alias ..='cd ..'
alias py='uv run python'
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

# ホスト名から決定論的に色を生成（成分2〜5、第2引数以降の色は避ける）
device_color() {
    local key=$1; shift
    local avoid=("$@") salt=0 color
    while :; do
        local hash=$(printf '%s' "${key}:${salt}" | cksum | cut -d ' ' -f 1)
        local r=$(( 2 + (hash)       % 4 ))
        local g=$(( 2 + (hash / 4)   % 4 ))
        local b=$(( 2 + (hash / 16)  % 4 ))
        color=$(( 16 + 36 * r + 6 * g + b ))
        [[ ${avoid[(r)$color]} != $color ]] && break
        (( salt++ ))
    done
    print $color
}

# 色を固定したいデバイスのみ "zsh git dir" で指定（任意）
typeset -A color_overrides
color_overrides=(
    Mokuichi147-MacBook "197 92 147"
)

if [[ -n ${color_overrides[$zsh_hostname]} ]]; then
    color_set=(${=color_overrides[$zsh_hostname]})
    zsh_color=$color_set[1]
    git_color=$color_set[2]
    dir_color=$color_set[3]
else
    zsh_color=$(device_color "$zsh_hostname")
    git_color=$(device_color "${zsh_hostname}:git" $zsh_color)
    dir_color=$(device_color "${zsh_hostname}:dir" $zsh_color $git_color)
fi

# デバイス固有の環境設定
case $zsh_hostname in
    Mokuichi147-MacBook)
    export LIBRARY_PATH="$LIBRARY_PATH:/usr/local/lib"
    export PATH="$HOME/.nodebrew/current/bin:$PATH"
    # FFmpeg
    #alias ffmpeg='$HOME/Documents/ffmpeg'
    ;;
esac

# pass
ZSH_DIR="$HOME/dotfiles/privates"

if [ -d $ZSH_DIR ] && [ -r $ZSH_DIR ] && [ -x $ZSH_DIR ]; then
    for file in ${ZSH_DIR}/**/*.zsh; do
        [ -r $file ] && source $file
    done
fi

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

# chpwd
function show_directory() {
    ls -a
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd show_directory

# git branch
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '%b, '
zstyle ':vcs_info:*' actionformats '%b|%a, '
precmd() { vcs_info }
setopt prompt_subst

# prompt
#zsh_clock='%B%F{$zsh_color}%*, %f'
#zsh_dir='%F{$dir_color}%~%f'

PROMPT='%B%F{$zsh_color}%*, %f%F{$git_color}${vcs_info_msg_0_}%f%F{$dir_color}%~%f
%F{$zsh_color}>%f%b '
