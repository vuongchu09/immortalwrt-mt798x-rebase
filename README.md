# ImmortalWrt MT798x cho router Viettel

Firmware ImmortalWrt 25.12 cho **Viettel NR3053**, dựa trên [chasey-dev/immortalwrt-mt798x-rebase](https://github.com/chasey-dev/immortalwrt-mt798x-rebase). Nhánh `main` hiện chỉ build và phát hành firmware NR3053.

## Thiết bị trong bản build

| | Viettel NR3053 |
|---|---|
| SoC | MediaTek MT7981B |
| RAM | 512 MB DDR3 |
| Flash | 128 MB SPI-NAND (UBI) |
| Cổng mạng | 3 LAN + 1 WAN |
| IP LAN mặc định | `192.168.1.1` |
| Trạng thái | Đã test phần cứng |

## Dùng firmware có sẵn

Tải bản mới nhất tại [Releases](https://github.com/vuongchu09/immortalwrt-mt798x-rebase/releases), rồi chọn file **đúng model**.

| File | Mục đích |
|---|---|
| `*-squashfs-sysupgrade.itb` | Cài đặt hoặc nâng cấp vĩnh viễn |
| `*-initramfs-recovery.itb` | Boot qua TFTP để test hoặc recovery, không ghi NAND |
| `*-bl31-uboot.fip` | Nâng cấp U-Boot — tải từ [quytttb/bl-mt798x-dhcpd Releases](https://github.com/quytttb/bl-mt798x-dhcpd/releases) |
| `*-preloader.bin` | Nâng cấp BL2 — rủi ro cao, tải từ [quytttb/bl-mt798x-dhcpd Releases](https://github.com/quytttb/bl-mt798x-dhcpd/releases) |

> Release này chỉ dành cho NR3053. Đọc [hướng dẫn nạp firmware](docs/huong-dan-nap-firmware.md) và chọn file `*-squashfs-sysupgrade.itb` trước khi nâng cấp.

## Điểm chính của bản fork

- LED WAN riêng cho NR3053.
- Aurora, WireGuard và AdGuard Home đã có trong firmware. AGH tự cấu hình sau flash mới: web UI port 3000, DNS port 5353, upstream WAN/ISP và Cloudflare fallback; dnsmasq/DHCP được nối sẵn.
- Không cài TurboACC, EQoS, UPnP, DDNS, Tailscale, SQM, terminal web, Samba hoặc Adblock cũ.
- Profile build và Release hiện chỉ chọn NR3053, không tạo firmware 32X6.
- Band steering được hỗ trợ ở driver nhưng tắt mặc định (`BandSteering=0`).
- NR3053 dùng toàn bộ UBI còn lại làm overlay; luôn chừa dung lượng trống cho hệ thống và nâng cấp.

## Build từ mã nguồn

Yêu cầu Ubuntu/Debian hoặc môi trường tương đương, đủ RAM và dung lượng đĩa cho OpenWrt.

```bash
git clone https://github.com/quytttb/immortalwrt-mt798x-rebase.git
cd immortalwrt-mt798x-rebase
bash scripts/install-deps.sh
bash scripts/build-viettel.sh
```

Build script chuẩn bị feeds, áp dụng bản dịch, chọn cấu hình NR3053, build firmware và bootloader rồi chép artifact vào `dist/`. Script kiểm tra 4 file NR3053, `sha256sums` và sinh `dist/release-notes.md`.

Để chỉ tạo image cho một thiết bị sau khi đã build package:

```bash
make target/linux/install V=s TARGET=mediatek SUBTARGET=filogic DEVICE=viettel_nr3053
```

Kết quả gốc nằm trong `bin/targets/mediatek/filogic/`; luôn kiểm tra `sha256sums` trước khi nạp.

## Nạp và khôi phục

Hướng dẫn đầy đủ có TFTP, U-Boot bootmenu, UART, sysupgrade và recovery:

- [Nạp firmware](docs/huong-dan-nap-firmware.md)
- [Cấu hình AdGuard Home và WireGuard](docs/huong-dan-tinh-nang-mo-rong.md)
- [Nghiên cứu MediaTek EasyMesh cho NR3053](docs/trien-khai-mediatek-easymesh.md)

Quy trình an toàn: boot `initramfs-recovery.itb` qua TFTP để test trước, sau đó mới ghi `squashfs-sysupgrade.itb`. Chỉ nâng cấp FIP hoặc BL2 khi có lý do cụ thể và đã chuẩn bị đường recovery.

## Bootloader (U-Boot / BL2)

Source và release chính thức của file `*-bl31-uboot.fip` và `*-preloader.bin` nằm tại:

**[quytttb/bl-mt798x-dhcpd](https://github.com/quytttb/bl-mt798x-dhcpd)** — tải từ tab [Releases](https://github.com/quytttb/bl-mt798x-dhcpd/releases).

`scripts/build-viettel.sh` pin một commit của repo này, build FIP/BL2 một lần
sau firmware, rồi gom chúng vào `dist/`; source firmware không còn tự build
U-Boot/TF-A. BL2 RAM payload dùng cho `mtk_uartboot` cũng lấy từ repo đó.

## Đồng bộ upstream

Fork fetch trực tiếp từ [chasey-dev/25.12](https://github.com/chasey-dev/immortalwrt-mt798x-rebase/tree/25.12); không giữ nhánh mirror `25.12` riêng. Workflow **Sync Upstream** chạy mỗi thứ Hai lúc 10:17 giờ Việt Nam hoặc có thể chạy tay từ tab **Actions**.

Khi upstream có thay đổi, workflow merge vào nhánh PR riêng và tạo/cập nhật pull request, không tự merge vào `main`. DTS LED và README được bảo vệ bằng `merge=ours`; `DEVICE_PACKAGES` được tách ở file fork riêng. Vẫn cần review PR khi upstream đổi image layout, partition hoặc board files dùng chung. Nếu merge conflict, maintainer giải quyết bằng Git trên nhánh sync rồi mở PR.

## Đóng góp và ghi công

- Báo lỗi hoặc đề xuất tính năng: mở Issue trên fork.
- Patch chung cho upstream: tạo nhánh từ `chasey-dev/25.12`, mỗi PR chỉ cho một thiết bị.
- Tính năng riêng cho Viettel: phát triển trên `main`.

Nền tảng: [ImmortalWrt](https://immortalwrt.org/), MediaTek OpenWrt feeds và [chasey-dev/immortalwrt-mt798x-rebase](https://github.com/chasey-dev/immortalwrt-mt798x-rebase).
