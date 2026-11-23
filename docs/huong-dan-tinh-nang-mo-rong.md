# Tính năng có sẵn trên ImmortalWrt NR3053

Firmware được build riêng cho **Viettel NR3053**; IP LAN mặc định là `192.168.1.1`.

## Có sẵn trong firmware

| Tính năng | Menu / địa chỉ |
|-----------|----------------|
| AdGuard Home | LuCI → **Services → AdGuard Home** |
| WireGuard VPN | LuCI → **Network → Interfaces** |

AdGuard Home được cấu hình tự động khi **flash mới** firmware. dnsmasq giữ port 53, chuyển tiếp truy vấn DNS sang AGH port 5353; DHCP cấp DNS router `192.168.1.1` cho client.

## AdGuard Home

- DNS listener: `0.0.0.0:5353`.
- Web UI: `http://192.168.1.1:3000`.
- Upstream ưu tiên DNS do WAN/ISP cấp; nếu WAN không cấp DNS, dùng Cloudflare `1.1.1.1` và `1.0.0.1`.
- Cloudflare cũng được cấu hình làm fallback khi upstream WAN không phản hồi.
- AGH tự enable và dnsmasq được cấu hình tự động sau first boot; không cần chạy wizard để DNS hoạt động.

**Lưu ý bảo mật:** giao diện AGH được bind vào IP LAN router và mặc định không bật đăng nhập AGH riêng. Chỉ thiết bị trong LAN mới truy cập được; không mở port 3000 ra WAN.

Sau khi flash, client có thể cần renew DHCP lease hoặc reconnect Wi-Fi để nhận DNS router. Cấu hình này áp dụng cho flash mới; khi nâng cấp sysupgrade, các file cấu hình trong `/etc` hiện có sẽ được giữ theo cơ chế OpenWrt.

Để giảm bộ nhớ, giữ filter list vừa phải và tránh bật nhiều danh sách trùng lặp.

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
