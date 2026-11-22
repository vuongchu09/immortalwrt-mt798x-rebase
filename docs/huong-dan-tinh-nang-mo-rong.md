# Tính năng có sẵn trên ImmortalWrt NR3053

Firmware được build riêng cho **Viettel NR3053**; IP LAN mặc định là `192.168.1.1`.

## Có sẵn trong firmware

| Tính năng | Menu / địa chỉ |
|-----------|----------------|
| AdGuard Home | LuCI → **Services → AdGuard Home** |
| WireGuard VPN | LuCI → **Network → Interfaces** |

AdGuard Home đã được cài sẵn nhưng dịch vụ mặc định đang tắt để tránh tranh cổng DNS với dnsmasq trước khi cấu hình.

## AdGuard Home

1. Vào **Services → AdGuard Home**, bật **Enable**, rồi **Save & Apply**.
2. Mở `http://192.168.1.1:3000` để hoàn tất trình hướng dẫn lần đầu và đặt mật khẩu quản trị.
3. Trong trình hướng dẫn, đặt cổng DNS của AdGuard Home là `5353` để không chiếm cổng `53` đang dùng bởi dnsmasq.
4. Sau khi hoàn tất, vào **Network → DHCP and DNS → DNS forwardings** và đặt `127.0.0.1#5353` làm DNS chuyển tiếp; lưu cấu hình rồi kiểm tra phân giải DNS từ thiết bị trong LAN.
5. Chỉ bật một bộ lọc quảng cáo. Sau khi AGH hoạt động, không cần cài lại Adblock cũ.

Để giảm bộ nhớ, bắt đầu với bộ lọc mặc định và thêm một danh sách phù hợp Việt Nam; tránh bật nhiều danh sách lớn cùng lúc. Trong trang **Services → AdGuard Home → Advanced Settings**, có thể đặt giới hạn bộ nhớ Go (GOMEMLIMIT) nếu cần.

Nếu DNS không hoạt động sau khi bật AGH, khôi phục DNS forwardings về cấu hình trước đó từ **Network → DHCP and DNS**.

## WireGuard VPN

### Điều kiện truy cập từ bên ngoài

- Mở chuyển tiếp cổng **UDP 51820** trên modem tới địa chỉ WAN của NR3053.
- Nếu địa chỉ IP công cộng thay đổi, cần một hostname DDNS tự cấu hình; gói DDNS không có sẵn trong firmware.

### Thông số tham khảo

| Mục | Giá trị |
|-----|---------|
| Interface | `wg0` |
| Subnet VPN | `10.66.66.1/24` |
| Listen port | `51820` |
| Firewall zone | `vpn` ↔ `lan` |

Cấu hình qua **Network → Interfaces → Add new interface → WireGuard**. Với NAT kép, modem chính cũng phải mở UDP 51820 tới NR3053.

## Hướng dẫn liên quan

- [Nạp / nâng cấp firmware](huong-dan-nap-firmware.md)
- [README](../README.md)
- [Trạng thái MediaTek EasyMesh](trien-khai-mediatek-easymesh.md)
