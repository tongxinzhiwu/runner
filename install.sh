#!/bin/bash

set -e

VERSION=""

GITHUB_ORG="tongxinzhiwu"
GITHUB_REPO="runner"

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m | tr '[:upper:]' '[:lower:]')

echo [INFO] OS=$OS
echo [INFO] ARCH=$ARCH

# adapt windows
if [[ "$OS" =~ msys* ]] || [[ "$OS" =~ mingw* ]] || [[ "$OS" =~ cygwin* ]] || [[ "$OS" =~ windows* ]]; then
  OS="windows"
fi

if [ "x86_64" = "$ARCH" ]; then
  ARCH="amd64"
fi

if [ "aarch64" = "$ARCH" ];then
  ARCH="arm64"
fi

if [ "armv7l" = "$ARCH" ];then
  ARCH="armv7"
fi

# check if curl is installed
if ! command -v curl &> /dev/null
then
    echo "curl could not be found"
    exit
fi

# if not specified, get the latest version
if [ -z "$VERSION" ]; then
  VERSION=$(curl --silent "https://api.github.com/repos/$GITHUB_ORG/$GITHUB_REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
fi

# download runner
DOWNLOAD_URL="https://github.com/$GITHUB_ORG/$GITHUB_REPO/releases/download/$VERSION/runner-$OS-$ARCH".tar.gz
echo [INFO] Downloading runner...
echo [INFO] URL: "$DOWNLOAD_URL"

curl -L --insecure -o runner.tar.gz "$DOWNLOAD_URL"

# extract runner
echo [INFO] Extracting runner...
tar -xzf runner.tar.gz


# install runner
echo [INFO] Installing runner...

RUNNER_PATH="runner-$OS-$ARCH/runner"

# if is windows, add .exe
if [ "$OS" = "windows" ]; then
  RUNNER_PATH="$RUNNER_PATH.exe"
fi

chmod +x "$RUNNER_PATH"

# make sure /usr/local/bin exists and is writable
BIN_PATH="${HOME}"/.runner/runner
mkdir -p "$BIN_PATH"
mv "$RUNNER_PATH" "$BIN_PATH"

# export path
echo [INFO] Adding "$BIN_PATH" to PATH...
echo "export PATH=\$PATH:$BIN_PATH" >> ~/.profile
source ~/.profile
echo "the runner bin path is $BIN_PATH"

# cleanup
echo [INFO] Cleaning up...
rm runner.tar.gz
rm -rf "runner-$OS-$ARCH"

# version
echo [INFO] echo "$(runner -v)"

# done
echo [INFO] Installation complete.
echo [INFO] Run 'runner --help' to get started.
