#!/bin/sh
set -eu
[ "$(id -u)" = "0" ] || { echo "Run as root" >&2; exit 1; }
BACKUP=/root/dns-failover-package-backup
STATE="$BACKUP/service-state"
/etc/init.d/dns-failover stop 2>/dev/null || true
/etc/init.d/dns-failover disable 2>/dev/null || true
restore_or_remove() {
    target="$1"; key="$(echo "$target" | sed 's#/#_#g')"
    if [ -e "$BACKUP$key" ]; then cp -p "$BACKUP$key" "$target"; else rm -f "$target"; fi
}
restore_or_remove /etc/config/dns-failover
restore_or_remove /etc/init.d/dns-failover
restore_or_remove /usr/sbin/dns-failover
restore_or_remove /usr/share/rpcd/acl.d/luci-app-dns-failover.json
restore_or_remove /usr/share/luci/menu.d/luci-app-dns-failover.json
restore_or_remove /www/luci-static/resources/view/dns-failover/config.js
rmdir /www/luci-static/resources/view/dns-failover 2>/dev/null || true
if [ -f "$STATE" ] && [ -x /etc/init.d/dns-failover ]; then
    if [ "$(cat "$STATE")" = enabled ]; then
        /etc/init.d/dns-failover enable
        /etc/init.d/dns-failover start
    else
        /etc/init.d/dns-failover disable
    fi
fi
/etc/init.d/rpcd restart
/etc/init.d/uhttpd reload 2>/dev/null || true
echo "Removed; original files and service enabled state restored where backed up."
echo "Backup retained at $BACKUP"
