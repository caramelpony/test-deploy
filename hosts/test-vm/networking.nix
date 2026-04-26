{ ... }:
# IPv6-only static config.
# If the interface name differs, check with `ip link` on the running rescue system
# and replace "eth0" below — common alternatives: ens3, enp1s0, enp2s0.
{
  networking.useDHCP = false;

  networking.interfaces.ens18 = {
    useDHCP = false;
    ipv6.addresses = [
      { address = "2602:fbec:224:0:be24:11ff:fe0d:d151"; prefixLength = 64; }
    ];
  };

  # Confirm the gateway with your hosting provider; fe80::1 is a common default.
  networking.defaultGateway6 = {
    address = "2602:fbec:224::254";
    interface = "ens18";
  };

  networking.nameservers = [
    "2606:4700:4700::1111"   # Cloudflare IPv6
    "2620:fe::fe"            # Quad9 IPv6
  ];
}
