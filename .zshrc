# Python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

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

# Android SDK
export PATH="$HOME/cmdline-tools/latest/bin:$PATH"
export NDK="$HOME/ndk-bundle"
export TOOLCHAIN="$NDK/toolchains/llvm/prebuilt/linux-x86_64"
export PATH="$TOOLCHAIN/bin:$PATH"
export TARGET="aarch64-linux-android"
export API="21"
export ANDROID_NDK_HOME="$NDK"

# openssl
#export OPENSSL_DIR="$HOME/openssl-1.1.1q"
export OPENSSL_DIR="/usr/local"
export CMAKE_CXX_COMPILER="/usr/bin/cmake"

# Wasmer
export WASMER_DIR="$HOME/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"

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
    # Java
    export JAVA_HOME="/usr/local/Cellar/openjdk/16.0.1/bin"
    # Flutter
    export PATH="$HOME/Documents/flutter/bin:$PATH"
    # Blender
    alias blender='/Applications/Blender.app/Contents/MacOS/Blender'
    # FFmpeg
    #alias ffmpeg='$HOME/Documents/ffmpeg'
    # opus-tools
    export PATH="$HOME/Documents/opus-tools-0.1.9-macos:$PATH"
    # OpenCVSharp
    #export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/Users/mokuichi147/github/opencvsharp/src/OpenCvSharpExtern"
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
    export PATH="$HOME/Documents/swift-5.2.4-RELEASE-ubuntu20.04/usr/bin:$PATH"
    ;;
    *)
    zsh_color=27
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
