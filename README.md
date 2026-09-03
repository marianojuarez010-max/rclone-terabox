# rclone-terabox

rclone with a TeraBox backend, and a QR-code login so no cookie is ever copied by hand.

TeraBox publishes no API and issues no developer keys. Every third-party client, this one included, works with the session token the TeraBox website itself uses. The backend here is x1arch's contribution to rclone, [pull request 8508](https://github.com/rclone/rclone/pull/8508), which has been waiting for a merge since April 2025. This repository lays it over a pinned rclone release, builds the binary, and adds a login helper that obtains the token by letting you scan a QR code with the TeraBox phone app.

## What you get

- `bin/rclone`: rclone with the `terabox` backend. Everything rclone does, `ls`, `copy`, `sync`, `mount`, `check`, works against `terabox:`.
- `bin/terabox-login`: shows a QR code, waits for the TeraBox app on your phone to confirm, and writes the remote into rclone's config.

## Requirements

- Linux or macOS with git and a Go toolchain new enough for the pinned rclone release (Go 1.25 for v1.75.0).
- Python 3 for the login helper. OpenCV and `qrencode` are optional: with them the QR code prints inside the terminal, without them it opens as an image.
- For `mount`, FUSE (`fusermount3`), present on most Linux desktops.

## Build

    ./build.sh

Clones rclone at the pinned release into `.build/`, copies `overlay/` onto it, and compiles `bin/rclone`. Rebuilds take seconds once the Go cache is warm. To build against another release: `RCLONE_VERSION=v1.76.0 ./build.sh`.

## Log in

    bin/terabox-login

Scan the code with the TeraBox app on your phone and confirm there. The helper saves a remote named `terabox:` and prints the account's quota. Options: `--remote NAME`, `--domain URL`, `--timeout SECONDS`.

The remote is stored with `domain = https://www.nephobox.com`, an alias TeraBox itself uses, which stays reachable on networks where `terabox.com` is blocked. The token sits in `~/.config/rclone/rclone.conf` like any other rclone credential; run the helper again when it expires, which the backend author puts at about a year.

## Everyday use

    bin/rclone lsd terabox:
    bin/rclone copy terabox:Videos/clip.mov ~/Videos/
    bin/rclone mount terabox: ~/terabox --vfs-cache-mode writes --vfs-cache-max-size 2G --daemon
    fusermount3 -u ~/terabox

The mount streams files on demand. Nothing is stored locally except files being written, which stage under `~/.cache/rclone` until uploaded, and the read cache, capped by `--vfs-cache-max-size`. Put `bin/` on your PATH if you prefer plain `rclone` commands.

## Limits

As reported by the backend author, not changed here:

- Uploads are capped at 4 GB per file on free accounts and 128 GB on premium.
- Empty files cannot be uploaded.
- Downloads run at roughly 2 MB/s on free accounts and 8 MB/s on premium; uploads at about 15 MB/s.
- Server-side copy is asynchronous, so concurrent copies fail with an "unfinished tasks" error.

## Layout

- `overlay/` mirrors rclone's source tree: the backend under `backend/terabox`, its registration in `backend/all/terabox.go`, and its metadata in `docs/data/backends/terabox.yaml`.
- `build.sh` pins the rclone release and does the copy and compile.
- `bin/terabox-login` stands alone; it needs an rclone binary only to write the config, found beside it or on PATH.

## Licence

MIT, as rclone itself; the backend is x1arch's work, contributed to rclone under that licence, and LICENSE carries both notices.
