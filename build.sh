#!/usr/bin/env bash
# Builds rclone with the TeraBox backend into bin/rclone.
# overlay/ mirrors rclone's source tree and is copied onto a pinned checkout.
# Requires git and a Go toolchain new enough for the pinned rclone release.
set -euo pipefail

RCLONE_VERSION="${RCLONE_VERSION:-v1.75.0}"

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$here/.build/rclone"

if [ ! -d "$src/.git" ]; then
    git clone --depth 1 --branch "$RCLONE_VERSION" https://github.com/rclone/rclone.git "$src"
fi
git -C "$src" checkout -q -- .
git -C "$src" clean -qfd .
cp -r "$here/overlay/." "$src/"

mkdir -p "$here/bin"
(cd "$src" && go build -o "$here/bin/rclone" .)
echo "built $here/bin/rclone: $("$here/bin/rclone" version | head -1)"
