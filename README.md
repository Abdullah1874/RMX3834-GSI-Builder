<div align="center">

# 🛠️ RMX3834 GSI Builder & Patcher
**Automated Cloud CI Pipeline for Building Device-Tailored GSIs for Realme Note 50 (`RMX3834`)**

[![Device](https://img.shields.io/badge/Device-Realme%20Note%2050%20(RMX3834)-yellow?style=for-the-badge&logo=android)](https://github.com/)
[![SoC](https://img.shields.io/badge/SoC-Unisoc%20Tiger%20T612%20(ums9230)-blue?style=for-the-badge&logo=linux)](https://github.com/)
[![CI Status](https://img.shields.io/badge/GitHub%20Actions-Active%20WIP-success?style=for-the-badge&logo=githubactions)](https://github.com/)
[![Filesystem](https://img.shields.io/badge/FS-EROFS%20%7C%20EXT4-orange?style=for-the-badge)](https://github.com/)

</div>

---

## 📖 Overview

**RMX3834-GSI-Builder** is an automated GitHub Actions kitchen designed specifically for the **Realme Note 50 (`RMX3834`)**. 

While Generic System Images (GSIs) from maintainers like **Doze-off (dotj)**, **Ponce**, **AndyYan**, and **Nazim** boot on Project Treble devices, running a raw GSI often requires manual post-install tweaking for device-specific quirks. This repository automates the process of downloading any upstream `.img` or `.img.xz` GSI release, mounting the filesystem, injecting **RMX3834-specific overlays, properties, and vendor fixes**, and repacking it into a ready-to-flash image.

---

## ✨ Key Features & Project Goals

* 🌐 **Direct URL Fetching:** Paste any direct download link (`.img`, `.xz`, `.gz`, `.zip`) from any GSI maintainer into the GitHub Actions workflow input.
* 🎨 **RMX3834 Hardware Overlay Injection:** Automatically injects RRO overlays tailored for the Realme Note 50 (correct status bar padding, waterdrop notch cutout, auto-brightness arrays, and refresh rate profiles).
* 🔧 **Unisoc T612 (`ums9230_hulk`) Prop Tuning:** Appends device-specific `build.prop` configurations for smoother UI rendering, audio routing, and memory management on 4GB RAM variants.
* 📦 **EROFS & EXT4 Repacking:** Supports unpacking read-only EROFS or EXT4 images and repacking them into compressed EROFS (for space-saving inside `super`) or RW-capable EXT4 images.
* 🧩 **Prebuilt Partition Integration *(WIP)*:** Integrates stock RMX3834 partitions (`vendor.img`, `product.img`, `system_ext.img`, `boot.img`, `vendor_boot.img`, `dtbo.img`) for optional full `super.img` generation or bundled fastboot flashable packages.

---

## 📱 Target Device Specifications

* **Device:** Realme Note 50
* **Model:** `RMX3834`
* **Board / Platform:** `ums9230_hulk` (Unisoc Tiger T612)
* **Architecture:** `arm64-v8a` (64-bit Binder)
* **Treble Layout:** `system-as-root` (A/B Dynamic Partitions - `arm64_bgN` / `arm64_bvN`)

---

## 🚀 How to Use (GitHub Actions Workflow)

1. **Fork** this repository to your GitHub account.
2. Navigate to the **Actions** tab in your forked repository.
3. Select the **Build & Patch RMX3834 GSI** workflow on the left sidebar.
4. Click the **Run workflow** dropdown button and fill in the parameters:
   * **`gsi_url`**: Paste the direct `.img.xz` or `.img` download link (e.g., from Doze-off, crDroid, LineageOS, or Evolution X GSI releases).
   * **`rom_name`**: Name of the ROM for the output file (e.g., `crDroid-12.12` or `LineageOS-23.2`).
   * **`output_fs`**: Choose between `erofs` (recommended, smaller & faster) or `ext4`.
   * **`compress_xz`**: Choose `true` to compress the final output as `.img.xz` or `false` for raw `.img`.
5. Wait for the runner to finish patching and repacking. Download your customized RMX3834 build from the **Releases** or **Artifacts** section!

---

## 🗺️ Development Roadmap

- [x] Initialize repository structure and workflow blueprint
- [x] Configure GitHub Actions environment with `erofs-utils`, `android-sdk-libsparse-utils`, and `xz-utils`
- [ ] Upload stock RMX3834 vendor/boot/dtbo reference blobs to GitHub Releases
- [ ] Extract and compile standalone RMX3834 hardware overlay APK (`treble-overlay-realme-rmx3834.apk`)
- [ ] Implement automated `system.prop` and Phh-Treble setting injection script
- [ ] Add `lpmake` script to optionally compile a full flashable `super.img` combining GSI `system` + stock `vendor`, `product`, and `system_ext`

---

## ⚠️ Disclaimer

> Flashing custom system images carries inherent risks. Always ensure your bootloader is unlocked, keep a backup of your stock `boot.img`, `vbmeta.img`, and `super.img` (or stock `.pac` firmware), and flash at your own responsibility.

---

## 🤝 Credits & Acknowledgments

* **[Phhusson](https://github.com/phhusson)** & **[TrebleDroid](https://github.com/TrebleDroid)** for the core Project Treble GSI foundation and hardware overlays.
* Upstream GSI maintainers (**Doze-off / dotj**, **Ponce**, **AndyYan**, **Nazim**, **MisterZtr**) for their continuous GSI builds.
