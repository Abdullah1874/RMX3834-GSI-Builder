<div align="center">

# 🛠️ RMX3834 GSI Builder & Optimizer
**Automated Cloud CI Kitchen for Building & Slimming Device-Tailored GSIs for Realme Note 50 (`RMX3834`)**

[![Device](https://img.shields.io/badge/Device-Realme%20Note%2050%20(RMX3834)-yellow?style=for-the-badge&logo=android)](https://github.com/)
[![SoC](https://img.shields.io/badge/SoC-Unisoc%20Tiger%20T612%20(ums9230)-blue?style=for-the-badge&logo=linux)](https://github.com/)
[![VNDK](https://img.shields.io/badge/VNDK-33%20%7C%2034-purple?style=for-the-badge)](https://github.com/)
[![Filesystem](https://img.shields.io/badge/FS-EROFS%20%7C%20EXT4-orange?style=for-the-badge)](https://github.com/)

</div>

---

## 📖 Overview

**RMX3834-GSI-Builder** is an automated GitHub Actions pipeline built for the **Realme Note 50 (`RMX3834` / `ums9230_hulk`)**. 

Upstream Generic System Images (GSIs) from maintainers like **Doze-off (dotj)**, **Ponce**, **AndyYan**, and **Nazim** are designed to support hundreds of devices simultaneously. Because of that, they bundle legacy VNDK APEX packages (v28–v32), ratusan unused hardware keylayouts, and generic configurations that waste **300MB–600MB+** of space inside the RMX3834's dynamic `super` partition.

This repository takes any direct GSI download URL, unpacks the filesystem (whether `EXT4` or `EROFS`), strips unneeded VNDK versions, removes irrelevant OEM hardware files, injects **RMX3834-specific configurations**, and repacks it into a clean, storage-optimized `.img` or `.img.xz` ready for flashing or DSU sideloading.

---

## ⚙️ Core Pipeline Features

* 🌐 **Universal GSI Input:** Supports direct links to `.img`, `.img.xz`, `.img.gz`, or `.zip` archives from any maintainer.
* 🧹 **Smart VNDK Stripping:** Automatically removes legacy VNDK APEXes (`v27` through `v32`) from `/system/system_ext/apex/`, keeping only `VNDK 33` and/or `VNDK 34` required by the Realme Note 50 vendor partition.
* 💾 **Dual Filesystem Output (`EROFS` / `EXT4`):**
  * **EROFS (`lz4hc`):** Compresses the read-only system partition for maximum free space inside `super` and faster random read speeds.
  * **EXT4 (`resize2fs -M`):** Builds a read/write-capable image shrunk to its minimum possible footprint.
* 🗑️ **Treble Keylayout & Bloat Cleanup:** Purges unused Phh keylayouts (Samsung, Xiaomi, Moto, Unihertz, gaming controllers) while preserving `Generic.kl`, `gpio-keys.kl`, `adaptive_ts.kl`, and Oppo/Realme touch configs.
* 🔧 **RMX3834 Hardware Patching:** Injects Unisoc `ums9230_hulk` system properties, Bluetooth A2DP offload fixes, and display configuration (`display_id_4619827259835644672.xml`).

---

## 📱 Target Device Profile

| Parameter | Specification |
| :--- | :--- |
| **Device** | Realme Note 50 (`RMX3834`) |
| **Platform / Board** | Unisoc Tiger T612 (`ums9230_hulk`) |
| **Architecture** | `arm64-v8a` (64-bit Binder, A/B Dynamic Partitions) |
| **Native Vendor VNDK** | VNDK 33 (Android 13) / VNDK 34 (Android 14) |
| **Display Config ID** | `4619827259835644672` |
| **Touch & Keylayout** | `adaptive_ts.kl`, `gpio-keys.kl` |

---

## 🚀 How to Build Your GSI

1. **Fork** this repository to your GitHub account.
2. Open the **Actions** tab and select **RMX3834 GSI Builder & Optimizer**.
3. Click **Run workflow** and configure your build options:
   * **`gsi_url`**: Direct download link to your chosen GSI release.
   * **`rom_name`**: Custom prefix for the output file (e.g., `crDroid-12.12-dotj`).
   * **`output_fs`**: Select `erofs` (recommended for size/performance) or `ext4` (if you need read/write system root).
   * **`vndk_cleanup`**: Select `keep-33-34` (safe default), `keep-33-only`, `keep-34-only`, or `none`.
   * **`debloat_gsi`**: Toggle removal of non-Realme Phh keylayouts and test packages.
   * **`inject_rmx3834_patches`**: Inject files and props located in `device/rmx3834/`.
   * **`publish_release`**: Automatically create a GitHub Release with the finished `.img.xz` file.
4. Once completed, download your tailored image from the workflow **Artifacts** or the repository **Releases** page.

---

## 📂 Adding RMX3834 Device Files (`device/rmx3834/`)

Any file placed inside `device/rmx3834/system/` mirrors `/system/` inside the GSI and is automatically copied over during step 2 of the pipeline:
* Place compiled hardware overlay APKs in `device/rmx3834/system/product/overlay/`
* Place display configs in `device/rmx3834/system/etc/displayconfig/`
* Add property overrides in `device/rmx3834/system.prop`

---

## ⚠️ Disclaimer

> Custom GSI images are provided without warranty. Always keep a backup of your stock `boot.img`, `vendor_boot.img`, `vbmeta.img`, and `super.img` before flashing via Fastbootd or DSU Sideloader.
