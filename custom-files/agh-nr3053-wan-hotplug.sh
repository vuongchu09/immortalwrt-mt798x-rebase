#!/bin/sh
# Update AGH upstreams from DNS servers provided by the WAN interface.
[ "$ACTION" = "ifup" ] || [ "$ACTION" = "ifupdate" ] || exit 0
[ "$INTERFACE" = "wan" ] || exit 0

CONFIG_DIR="/etc/adguardhome"
UPSTREAM_FILE="$CONFIG_DIR/upstream_dns.txt"
TMP_FILE="$CONFIG_DIR/upstream_dns.txt.tmp"

mkdir -p "$CONFIG_DIR"
: > "$TMP_FILE"

WAN_DNS="$(ubus call network.interface.wan status 2>/dev/null | jsonfilter -e '@.dns-server[*]' 2>/dev/null)"
for server in $WAN_DNS; do
    case "$server" in
        *:*)
            # Accept IPv6 literal addresses only; reject anything with other characters.
            echo "$server" | grep -Eq '^[0-9A-Fa-f:]+$' || continue
            ;;
        *)
            echo "$server" | grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$' || continue
            ;;
    esac
    grep -qxF "$server" "$TMP_FILE" 2>/dev/null || printf '%s\n' "$server" >> "$TMP_FILE"
done

# If WAN did not supply DNS, use Cloudflare as the active upstream as well as fallback.
if [ ! -s "$TMP_FILE" ]; then
    printf '%s\n' '1.1.1.1' '1.0.0.1' > "$TMP_FILE"
fi

if ! cmp -s "$TMP_FILE" "$UPSTREAM_FILE"; then
    mv "$TMP_FILE" "$UPSTREAM_FILE"
    chown adguardhome:adguardhome "$UPSTREAM_FILE" 2>/dev/null || true
    /etc/init.d/adguardhome restart >/dev/null 2>&1 || true
else
    rm -f "$TMP_FILE"
fi
exit 0
