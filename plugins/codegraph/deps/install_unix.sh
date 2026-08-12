#!/usr/bin/env bash
# CodeGraph-Rust CLI install for Darwin/Linux (sourced by platform entry scripts).
# Env: DANMO_HOME (required), optional CODEGRAPH_VERSION / CODEGRAPH_BASE_URL / CODEGRAPH_FORCE
set -euo pipefail

VERSION="${CODEGRAPH_VERSION:-0.42.6}"
VERSION="${VERSION#v}"
HOME_DIR="${DANMO_HOME:-}"
if [[ -z "$HOME_DIR" ]]; then
  echo "DANMO_HOME is required" >&2
  exit 1
fi
BIN_DIR="$HOME_DIR/bin"
mkdir -p "$BIN_DIR"

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64) CG_ARCH="amd64" ;;
  arm64|aarch64) CG_ARCH="arm64" ;;
  *)
    echo "Unsupported arch: $ARCH" >&2
    exit 1
    ;;
esac

OS_NAME="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "$OS_NAME" in
  darwin)
    case "$CG_ARCH" in
      arm64) TARGET="aarch64-apple-darwin"; SHA256="3625f4abcd80ce1af495538d6a763c0faee1ac844bdc9b7c5af1be9430047853" ;;
      amd64) TARGET="x86_64-apple-darwin"; SHA256="3567e1a948cecc04fcf2c578e52a99f082eebd4f3a2903e2890cc9a75d4aae4c" ;;
    esac
    EXT="tar.gz"
    DEST_BIN="$BIN_DIR/codegraph"
    DEST_ARCHIVE="$BIN_DIR/codegraph.tar.gz"
    ;;
  linux)
    case "$CG_ARCH" in
      arm64) TARGET="aarch64-unknown-linux-musl"; SHA256="5c2d03f634e06cb17bb680a54e7b7a9ed82558154bf4aa48ed32f41599391dc1" ;;
      amd64) TARGET="x86_64-unknown-linux-musl"; SHA256="e344f4a62789a4f7d2d4925d71811ec4a192430d619168b8dea47d4502f66e81" ;;
    esac
    EXT="tar.gz"
    DEST_BIN="$BIN_DIR/codegraph"
    DEST_ARCHIVE="$BIN_DIR/codegraph.tar.gz"
    ;;
  *)
    echo "Unsupported OS for unix installer: $OS_NAME" >&2
    exit 1
    ;;
esac

ASSET="codegraph-${VERSION}-${TARGET}.${EXT}"
VERSION_FILE="$BIN_DIR/CODEGRAPH_VERSION"
BASE_URL="${CODEGRAPH_BASE_URL:-https://github.com/sunerpy/codegraph-rust/releases/download/v${VERSION}}"
URL="${BASE_URL}/${ASSET}"

need_fetch=0
if [[ "${CODEGRAPH_FORCE:-}" == "1" ]]; then
  need_fetch=1
elif [[ ! -x "$DEST_BIN" ]]; then
  need_fetch=1
elif [[ ! -f "$VERSION_FILE" ]] || [[ "$(tr -d '[:space:]' <"$VERSION_FILE" 2>/dev/null || true)" != "$VERSION" ]]; then
  need_fetch=1
fi

if [[ "$need_fetch" -eq 0 ]]; then
  echo "==> CodeGraph already installed: $DEST_BIN (v${VERSION})"
  exit 0
fi

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

ARCHIVE="$TMP/$ASSET"
echo "==> Downloading CodeGraph-Rust v${VERSION} (${TARGET})"
echo "    $URL"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL -o "$ARCHIVE" "$URL"
elif command -v wget >/dev/null 2>&1; then
  wget -q -O "$ARCHIVE" "$URL"
else
  echo "curl or wget required" >&2
  exit 1
fi

GOT="$(shasum -a 256 "$ARCHIVE" 2>/dev/null | awk '{print $1}')"
if [[ -z "$GOT" ]]; then
  GOT="$(sha256sum "$ARCHIVE" | awk '{print $1}')"
fi
if [[ "${GOT}" != "${SHA256}" ]]; then
  echo "sha256 mismatch: want ${SHA256} got ${GOT}" >&2
  exit 1
fi

cp -f "$ARCHIVE" "$DEST_ARCHIVE"
mkdir -p "$TMP/out"
tar -xzf "$DEST_ARCHIVE" -C "$TMP/out"
FOUND="$(find "$TMP/out" -type f -name codegraph | head -n 1 || true)"
if [[ -z "$FOUND" ]]; then
  echo "codegraph binary not found in archive" >&2
  exit 1
fi
cp -f "$FOUND" "$DEST_BIN"
chmod +x "$DEST_BIN"
printf '%s\n' "$VERSION" >"$VERSION_FILE"
echo "==> Installed $DEST_BIN (v${VERSION})"
