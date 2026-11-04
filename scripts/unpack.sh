#!/usr/bin/env bash
set -euo pipefail

GSI_URL="$1"
WORK_DIR="$(pwd)/work"
mkdir -p "$WORK_DIR/mnt" "$WORK_DIR/extracted"
cd "$WORK_DIR"

echo "==> [1/4] Downloading GSI from: $GSI_URL"
aria2c -x16 -s16 --console-log-level=warn "$GSI_URL" -o source_archive

FILE_DESC=$(file -b source_archive)
echo "==> [2/4] Detected archive format: $FILE_DESC"

if echo "$FILE_DESC" | grep -qi "XZ compressed"; then
    xz -d -T0 source_archive -c > raw_or_sparse.img
elif echo "$FILE_DESC" | grep -qi "gzip compressed"; then
    gzip -d source_archive -c > raw_or_sparse.img
elif echo "$FILE_DESC" | grep -qi "Zip archive"; then
    7z e source_archive "*.img" -r -y
    rm -f source_archive
    IMG_FOUND=$(ls *.img | head -n 1)
    mv "$IMG_FOUND" raw_or_sparse.img
else
    mv source_archive raw_or_sparse.img
fi
rm -f source_archive

if file -b raw_or_sparse.img | grep -qi "Android sparse"; then
    echo "==> [3/4] Converting Android sparse image to raw image..."
    simg2img raw_or_sparse.img system.img
    rm -f raw_or_sparse.img
else
    mv raw_or_sparse.img system.img
fi

FS_TYPE=$(blkid -o value -s TYPE system.img || true)
echo "==> [4/4] Detected filesystem: ${FS_TYPE:-unknown}"

if [ "$FS_TYPE" = "erofs" ]; then
    echo "==> Extracting EROFS image with fsck.erofs..."
    sudo fsck.erofs --extract="$WORK_DIR/extracted" system.img
else
    echo "==> Mounting EXT4 image and copying root filesystem..."
    sudo mount -o loop,ro system.img "$WORK_DIR/mnt"
    sudo cp -a "$WORK_DIR/mnt/." "$WORK_DIR/extracted/"
    sudo umount "$WORK_DIR/mnt"
fi

rm -f system.img
echo "==> Unpack complete! Current extracted size:"
sudo du -sh "$WORK_DIR/extracted"
