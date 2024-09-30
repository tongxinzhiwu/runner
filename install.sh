#!/bin/bash

set -e

VERSION=""

GITHUB_ORG="tongxinzhiwu"
GITHUB_REPO="runner"

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m | tr '[:upper:]' '[:lower:]')

echo [INFO] OS=$OS
echo [INFO] ARCH=$ARCH

if [ "x86_64" = "$ARCH" ]; then
  # x86_64 is the default skip linux
  if [ "linux" != "$OS" ]; then
     ARCH=""
  fi
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
chmod +x "$RUNNER_PATH"
# make sure /usr/local/bin exists and is writable
sudo mkdir -p /usr/local/bin
sudo mv "$RUNNER_PATH" /usr/local/bin/runner

# cleanup
echo [INFO] Cleaning up...
rm runner.tar.gz
rm -rf "runner-$OS-$ARCH"

# version
echo [INFO] echo "$(runner -v)"

# done
echo [INFO] Installation complete.
echo [INFO] Run 'runner --help' to get started.