#!/bin/bash

os=$(uname -s)
arch=$(uname -m)
OS=${OS:-"${os}"}
ARCH=${ARCH:-"${arch}"}
OS_ARCH=""

echoerr() { echo "\$@" 1>&2; }

unsupported_arch() {
  local os=$1
  local arch=$2
  echoerr "GraphQL Hive CLI does not support $os / $arch at this time."
  echo "If you think that's a bug - please file an issue to https://github.com/kamilkisiela/graphql-hive/issues"
  exit 1
}

set_os_arch() {
  case $OS in
    CYGWIN* | MINGW64* | Windows*)
      if [ $ARCH = "x86_64" ]; then
        OS_ARCH="win32-x64"
      else
        unsupported_arch $OS $ARCH
      fi
      ;;
    Darwin)
      case $ARCH in
        x86_64 | amd64)
          OS_ARCH="darwin-x64"
          ;;
        arm64)
          OS_ARCH="darwin-arm64"
          ;;
        *)
          unsupported_arch $OS $ARCH
          ;;
      esac
      ;;
    Linux)
      case $ARCH in
        x86_64 | amd64)
          OS_ARCH="linux-x64"
          ;;
        arm64 | aarch64)
          OS_ARCH="linux-arm"
          ;;
        *)
          unsupported_arch $OS $ARCH
          ;;
      esac
      ;;
    *)
      unsupported_arch $OS $ARCH
      ;;
  esac
}

get_bin_path() {
  path="/usr/local/bin/${BIN_NAME}"
  if [ "${OS}" = 'windows' ]; then
    path="./${BIN_NAME}"
  fi

  echo "${path}"
}

download() {
  DOWNLOAD_DIR=$(mktemp -d)
  UNPACK_DIR=$(mktemp -d)
#   UNPACK_DIR="/usr/local/lib"

  URL="https://graphql-hive-cli.s3.us-east-2.amazonaws.com/channels/stable/hive-$OS_ARCH.tar.gz"
  echo "Downloading $URL"

  if ! curl --progress-bar --fail -L "$URL" -o "$DOWNLOAD_DIR/hive.tar.gz"; then
    echo "Download failed."
    exit 1
  fi

  echo "Downloaded to $DOWNLOAD_DIR"

  rm -rf "$UNPACK_DIR/hive"
  tar xzf "$DOWNLOAD_DIR/hive.tar.gz" -C "$UNPACK_DIR"
  rm -rf "$DOWNLOAD_DIR"
  echo "Unpacked to $UNPACK_DIR"

  echo "Installing to /usr/local/bin/hive"
  rm -f /usr/local/bin/hive
  rm -f /usr/local/lib/hive
  mv "${UNPACK_DIR}" /usr/local/lib
  ln -s /usr/local/lib/hive/bin/hive /usr/local/bin/hive
}

set_os_arch
download
hive
