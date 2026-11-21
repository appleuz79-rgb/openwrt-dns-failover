#!/bin/sh
set -eu

[ "$(id -u)" = "0" ] || { echo "Run as root"; exit 1; }
BASE="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
BACKUP="/root/dns-failover-package-backup"
mkdir -p "$BACKUP"

for f in /etc/config/dns-failover /etc/init.d/dns-failover /usr/sbin/dns-failover \
         /usr/share/rpcd/acl.d/luci-app-dns-failover.json \
         /www/luci-static/resources/view/dns-failover/config.js \
         /usr/share/luci/menu.d/luci-app-dns-failover.json; do
    if [ -e "$f" ] && [ ! -e "$BACKUP$(echo "$f" | sed 's#/#_#g')" ]; then
        cp -p "$f" "$BACKUP$(echo "$f" | sed 's#/#_#g')"
    fi
done

install -d /etc/config /etc/init.d /usr/sbin \
    /usr/share/rpcd/acl.d /usr/share/luci/menu.d \
    /www/luci-static/resources/view/dns-failover

install -m 0644 "$BASE/config/dns-failover" /etc/config/dns-failover
install -m 0755 "$BASE/files/etc/init.d/dns-failover" /etc/init.d/dns-failover
install -m 0755 "$BASE/files/usr/sbin/dns-failover" /usr/sbin/dns-failover
install -m 0644 "$BASE/acl/luci-app-dns-failover.json" /usr/share/rpcd/acl.d/luci-app-dns-failover.json
install -m 0644 "$BASE/files/usr/share/luci/menu.d/luci-app-dns-failover.json" /usr/share/luci/menu.d/luci-app-dns-failover.json
install -m 0644 "$BASE/files/www/luci-static/resources/view/dns-failover/config.js" /www/luci-static/resources/view/dns-failover/config.js

/etc/init.d/rpcd restart
/etc/init.d/uhttpd reload 2>/dev/null || true
/etc/init.d/dns-failover enable
/etc/init.d/dns-failover restart

echo "Installed in MONITOR + MANUAL mode. No DNS routing configuration was changed."
echo "Open LuCI: Services -> DNS Failover"
