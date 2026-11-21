# OpenWrt DNS Failover

Initial development package for OpenWrt 24.10. This first release is deliberately
conservative: it provides monitoring and manual transport selection. It does
**not** automatically rewrite dnsmasq upstreams or enable unattended failover.

## Target environment

- OpenWrt 24.10
- Mihomo REST API at `http://127.0.0.1:9090`
- Mihomo DNS listener at `127.0.0.1:5353`
- Mihomo selector `DNS-Transport`, members `WARP` and `My-VPS`

These defaults are configurable in `/etc/config/dns-failover`.

## Install

Upload/extract the release archive on the router, then run:

```sh
cd /tmp/openwrt-dns-failover
sh install.sh
```

The installer backs up existing DNS Failover files before replacing them.
It does not modify `/etc/mihomo/config.yaml`, `/etc/config/dhcp`, network
settings, IPv6 settings, or MagiTrickle.

## Commands

```sh
/etc/init.d/dns-failover status
/usr/sbin/dns-failover once
/usr/sbin/dns-failover select WARP
/usr/sbin/dns-failover select My-VPS
```

The monitor checks the Mihomo proxy delay endpoint and a real DNS response
through Mihomo's DNS API. A successful DNS API response proves the resolver
answered; it does not independently prove which proxy carried that DNS query.

## Safety

Automatic failover is intentionally not enabled in this initial package.
Direct ISP DNS fallback requires coordinated, reversible dnsmasq changes and
must be validated separately before it is introduced. Do not treat this
monitor/manual package as a complete automatic failover solution.

## Uninstall

```sh
sh uninstall.sh
```

Uninstall stops and disables this service and removes only files installed by
this package. It does not alter Mihomo or dnsmasq configuration.
