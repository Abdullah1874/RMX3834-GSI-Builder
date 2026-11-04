#!/usr/bin/env bash
set -euo pipefail

VNDK_MODE="$1"
DEBLOAT="$2"
INJECT_PATCHES="$3"

ROOT_DIR="$(pwd)/work/extracted"
# Handle both system-as-root layouts
if [ -d "$ROOT_DIR/system/system" ]; then
    SYS_DIR="$ROOT_DIR/system/system"
else
    SYS_DIR="$ROOT_DIR/system"
fi

echo "==> Target system directory: $SYS_DIR"

# 1. VNDK Cleanup
APEX_DIR="$SYS_DIR/system_ext/apex"
if [ "$VNDK_MODE" != "none" ] && [ -d "$APEX_DIR" ]; then
    echo "==> [VNDK] Size before cleanup: $(sudo du -sh "$APEX_DIR" | cut -f1)"
    
    # Always remove legacy VNDKs 27 through 32 (unused on RMX3834)
    sudo rm -rf "$APEX_DIR"/com.android.vndk.v2[7-9]*
    sudo rm -rf "$APEX_DIR"/com.android.vndk.v3[0-2]*

    if [ "$VNDK_MODE" = "keep-33-only" ]; then
        echo "==> [VNDK] Keeping VNDK 33 only (removing v34)..."
        sudo rm -rf "$APEX_DIR"/com.android.vndk.v34*
    elif [ "$VNDK_MODE" = "keep-34-only" ]; then
        echo "==> [VNDK] Keeping VNDK 34 only (removing v33)..."
        sudo rm -rf "$APEX_DIR"/com.android.vndk.v33*
    else
        echo "==> [VNDK] Keeping VNDK 33 and 34 for RMX3834 compatibility..."
    fi
    echo "==> [VNDK] Size after cleanup: $(sudo du -sh "$APEX_DIR" | cut -f1)"
fi

# 2. Debloat Unused OEM Keylayouts & Test Packages
if [ "$DEBLOAT" = "true" ]; then
    echo "==> [Debloat] Removing non-Realme Phh keylayouts and controller mappings..."
    if [ -d "$SYS_DIR/phh" ]; then
        sudo find "$SYS_DIR/phh" -type f -name "*.kl" ! -name "*oppo*" -delete || true
        sudo rm -rf "$SYS_DIR/phh/huawei" || true
    fi
    if [ -d "$SYS_DIR/usr/keylayout" ]; then
        # Remove Xbox/PlayStation/generic USB gamepad Vendor_*.kl bloat while keeping Generic.kl & AVRCP.kl
        sudo find "$SYS_DIR/usr/keylayout" -type f -name "Vendor_*.kl" -delete || true
    fi
fi

# 3. Inject RMX3834 Specific Patches & Props
if [ "$INJECT_PATCHES" = "true" ]; then
    echo "==> [RMX3834] Injecting device overlays, displayconfigs, and build.prop tweaks..."
    if [ -d "device/rmx3834/system" ]; then
        sudo cp -rf device/rmx3834/system/. "$SYS_DIR/"
    fi
    if [ -f "device/rmx3834/system.prop" ]; then
        echo "" | sudo tee -a "$SYS_DIR/build.prop" > /dev/null
        echo "# === RMX3834 (ums9230_hulk) Auto-Injected Properties ===" | sudo tee -a "$SYS_DIR/build.prop" > /dev/null
        cat "device/rmx3834/system.prop" | sudo tee -a "$SYS_DIR/build.prop" > /dev/null
    fi
fi

echo "==> Final system footprint before repacking:"
sudo du -sh "$ROOT_DIR"
