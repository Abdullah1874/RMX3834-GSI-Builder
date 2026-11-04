#!/usr/bin/env bash
set -euo pipefail

ROM_NAME="$1"
OUTPUT_FS="$2"
COMPRESS_XZ="$3"

WORK_DIR="$(pwd)/work"
ROOT_DIR="$WORK_DIR/extracted"
DATE_TAG=$(date +%Y%m%d)
OUT_IMG="$WORK_DIR/${ROM_NAME}-RMX3834-${OUTPUT_FS}-${DATE_TAG}.img"

if [ "$OUTPUT_FS" = "erofs" ]; then
    echo "==> Building compressed EROFS image ($OUT_IMG)..."
    sudo mkfs.erofs -zlz4hc,9 -T 1230768000 --mount-point=/ "$OUT_IMG" "$ROOT_DIR"
else
    echo "==> Calculating space and building minimized EXT4 image ($OUT_IMG)..."
    USED_MB=$(sudo du -sm "$ROOT_DIR" | cut -f1)
    # Add 15% buffer for ext4 inode/journal overhead before shrinking
    IMG_MB=$(( USED_MB + (USED_MB * 15 / 100) + 128 ))
    
    dd if=/dev/zero of="$OUT_IMG" bs=1M count="$IMG_MB" status=none
    sudo mkfs.ext4 -F -O ^metadata_csum -L "/" -b 4096 "$OUT_IMG"
    
    sudo mount -o loop "$OUT_IMG" "$WORK_DIR/mnt"
    sudo cp -a "$ROOT_DIR/." "$WORK_DIR/mnt/"
    sudo umount "$WORK_DIR/mnt"
    
    sudo e2fsck -fy "$OUT_IMG" || true
    sudo resize2fs -M "$OUT_IMG"
fi

sudo chown "$USER:$USER" "$OUT_IMG"
sudo rm -rf "$ROOT_DIR"

if [ "$COMPRESS_XZ" = "true" ]; then
    echo "==> Compressing image with XZ (-9 extreme, multithreaded)..."
    xz -9 -T0 "$OUT_IMG"
    FINAL_FILE="${OUT_IMG}.xz"
else
    FINAL_FILE="$OUT_IMG"
fi

echo "==> Build complete! Output file:"
ls -lh "$FINAL_FILE"
