#!/bin/bash
# Ensure a release contains every flashable artifact for NR3053 only.
set -euo pipefail

DIST_DIR="${1:-dist}"

[[ -d "$DIST_DIR" ]] || {
    echo "Artifact directory does not exist: $DIST_DIR" >&2
    exit 1
}

expected=(
    "immortalwrt-mediatek-filogic-viettel_nr3053-squashfs-sysupgrade.itb"
    "immortalwrt-mediatek-filogic-viettel_nr3053-initramfs-recovery.itb"
    "immortalwrt-mediatek-filogic-viettel_nr3053-bl31-uboot.fip"
    "immortalwrt-mediatek-filogic-viettel_nr3053-preloader.bin"
)

if compgen -G "$DIST_DIR/*viettel_32x6*" >/dev/null; then
    echo "Unexpected 32X6 artifacts in NR3053-only release." >&2
    exit 1
fi

for artifact in "${expected[@]}"; do
    [[ -s "$DIST_DIR/$artifact" ]] || {
        echo "Missing or empty required artifact: $DIST_DIR/$artifact" >&2
        exit 1
    }
done

checksum_file="$DIST_DIR/sha256sums"
[[ -s "$checksum_file" ]] || {
    echo "Missing checksum manifest: $checksum_file" >&2
    exit 1
}

(
    cd "$DIST_DIR"
    sha256sum --check --strict sha256sums
)

echo "NR3053 release artifacts OK (4 board-specific files and checksums)."
