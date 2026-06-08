# Python (uv)
export PATH="$HOME/.local/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# C#
export PATH="/usr/local/share/dotnet:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"
export DOTNET_CLI_TELEMETRY_OPTOUT="true"
export DOTNET_INTERACTIVE_CLI_TELEMETRY_OPTOUT="true"

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
alias tmux='tmux -u'

# OS
case ${OSTYPE} in
    darwin*)
    alias ls='ls -G'
    # PostgreSQL
    export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
    # OpenSSL
    export OPENSSL_DIR="/opt/homebrew/opt/openssl@3"
    # Java
    export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
    # Node
    export PATH="$HOME/.nodebrew/current/bin:$PATH"
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"
    . "$HOME/.deno/env"
    ;;
    linux*)
    alias ls='ls --color'
    alias i2c='sudo i2cdetect -y 1'
    ;;
esac

# host
zsh_hostname=$(hostname|cut -f 1 -d '.')

# ホスト名から決定論的に色を生成（成分2〜5）
device_color() {
    local key=$1
    local hash=$(printf '%s' "$key" | cksum | cut -d ' ' -f 1)
    local r=$(( 2 + (hash)       % 4 ))
    local g=$(( 2 + (hash / 4)   % 4 ))
    local b=$(( 2 + (hash / 16)  % 4 ))
    print $(( 16 + 36 * r + 6 * g + b ))
}

# 色を固定したいデバイスのみ指定（任意）
typeset -A color_overrides
color_overrides=(
    mokuichi147-MacBookAir "147"
)

if [[ -n ${color_overrides[$zsh_hostname]} ]]; then
    device_color=${color_overrides[$zsh_hostname]}
else
    device_color=$(device_color "$zsh_hostname")
fi

# zsh・git・dir はすべて同じ色を使う
zsh_color=$device_color
git_color=$device_color
dir_color=$device_color

# デバイス固有の環境設定
case $zsh_hostname in
    mokuichi147-MacBookAir)
    # LM Studio
    export PATH="$HOME/.lmstudio/bin:$PATH"
    # FFmpeg
    export PATH="$HOME/Documents/ffmpeg/out/bin:$PATH"
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

# 補完
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select                        # 矢印キーで補完候補を選択
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # 大文字小文字を区別しない
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}     # 補完候補に色付け
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''                      # 種類ごとにグループ表示
zstyle ':completion:*:descriptions' format '%B%F{'$zsh_color'}%d%f%b'
setopt auto_menu                                          # Tab連打で候補を順に選択
setopt auto_param_slash                                   # ディレクトリ補完で末尾に / を付与
setopt list_packed                                        # 補完候補をコンパクトに表示
setopt complete_in_word                                   # カーソル位置で補完

# zsh-autosuggestions (入力途中に補完表示)
zsh_autosuggest_paths=(
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh             # Debian/Ubuntu (apt)
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh # Arch 等
)

if (( $+commands[brew] )); then
    zsh_autosuggest_paths=(
        "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        $zsh_autosuggest_paths
    )
fi
for f in $zsh_autosuggest_paths; do
    [ -r "$f" ] && source "$f" && break
done
unset zsh_autosuggest_paths f
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'                         # 補完の文字色（薄いグレー）

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

PROMPT='%B%F{$zsh_color}%*, %f%F{$git_color}${vcs_info_msg_0_}%f%F{$dir_color}%~%f
%F{$zsh_color}>%f%b '
