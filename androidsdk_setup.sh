# Java
sudo apt-get install -y openjdk-17-jdk-headless

# Android SDK Manager
# URL: https://developer.android.com/studio
wget -P ~ https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip

# unzip and move ~/cmdline-tools/latest/*
unzip ~/commandlinetools-linux-8512546_latest.zip -d ~/cmdline-tools/latest
mv ~/cmdline-tools/latest/cmdline-tools/* ~/cmdline-tools/latest/
sudo rm -R ~/cmdline-tools/latest/cmdline-tools

# Path
# export PATH="$HOME/cmdline-tools/latest/bin:$PATH"

# Install
#sdkmanager install ndk-bundle
# ls ~/ndk-bundle