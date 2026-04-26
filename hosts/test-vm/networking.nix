{ ... }:
# ens18 — IPv6 (management/public)
# ens19 — IPv4 128.254.224.230/24 (used for CI deploy reachability)
{
  networking.useDHCP = false;

  networking.interfaces.ens18 = {
    useDHCP = false;
    ipv6.addresses = [
      { address = "2602:fbec:224:0:be24:11ff:fe0d:d151"; prefixLength = 64; }
    ];
  };

  networking.interfaces.ens19 = {
    useDHCP = false;
    ipv4.addresses = [
      { address = "128.254.224.230"; prefixLength = 24; }
    ];
  };

  networking.defaultGateway = {
    address = "128.254.224.1";
    interface = "ens19";
  };

  networking.defaultGateway6 = {
    address = "2602:fbec:224::254";
    interface = "ens18";
  };

  networking.nameservers = [
    "1.1.1.1"
    "2620:fe::fe"
  ];
}
