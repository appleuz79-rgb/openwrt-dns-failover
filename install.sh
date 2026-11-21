#!/bin/sh
set -eu
[ "$(id -u)" = "0" ] || { echo "Run as root" >&2; exit 1; }
BASE="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
BACKUP=/root/dns-failover-package-backup
STATE="$BACKUP/service-state"
for f in config/dns-failover files/etc/init.d/dns-failover files/usr/sbin/dns-failover acl/luci-app-dns-failover.json files/usr/share/luci/menu.d/luci-app-dns-failover.json files/www/luci-static/resources/view/dns-failover/config.js; do
    [ -f "$BASE/$f" ] || { echo "Missing $f" >&2; exit 1; }
done
for c in uci curl jsonfilter logger install; do
    command -v "$c" >/dev/null 2>&1 || { echo "Missing command: $c" >&2; exit 1; }
done
mkdir -p "$BACKUP"
if [ ! -f "$STATE" ]; then
    if [ -x /etc/init.d/dns-failover ] && /etc/init.d/dns-failover enabled >/dev/null 2>&1; then
        echo enabled > "$STATE"
    else
        echo disabled > "$STATE"
    fi
fi
backup_file() {
    src="$1"; key="$(echo "$src" | sed 's#/#_#g')"
    if [ -e "$src" ] && [ ! -e "$BACKUP$key" ]; then cp -p "$src" "$BACKUP$key"; fi
}
backup_file /etc/config/dns-failover
backup_file /etc/init.d/dns-failover
backup_file /usr/sbin/dns-failover
backup_file /usr/share/rpcd/acl.d/luci-app-dns-failover.json
backup_file /usr/share/luci/menu.d/luci-app-dns-failover.json
backup_file /www/luci-static/resources/view/dns-failover/config.js
install -d /etc/config /etc/init.d /usr/sbin /usr/share/rpcd/acl.d /usr/share/luci/menu.d /www/luci-static/resources/view/dns-failover
install -m 0644 "$BASE/config/dns-failover" /etc/config/dns-failover
install -m 0755 "$BASE/files/etc/init.d/dns-failover" /etc/init.d/dns-failover
install -m 0755 "$BASE/files/usr/sbin/dns-failover" /usr/sbin/dns-failover
install -m 0644 "$BASE/acl/luci-app-dns-failover.json" /usr/share/rpcd/acl.d/luci-app-dns-failover.json
install -m 0644 "$BASE/files/usr/share/luci/menu.d/luci-app-dns-failover.json" /usr/share/luci/menu.d/luci-app-dns-failover.json
install -m 0644 "$BASE/files/www/luci-static/resources/view/dns-failover/config.js" /www/luci-static/resources/view/dns-failover/config.js
/etc/init.d/dns-failover enable
/etc/init.d/dns-failover restart
/etc/init.d/rpcd restart
/etc/init.d/uhttpd reload 2>/dev/null || true
echo "Installed: monitor + manual mode only. DNS/Mihomo/network settings unchanged."
