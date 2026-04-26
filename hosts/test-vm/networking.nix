{ ... }:
# ens18 — IPv4 128.254.224.230/24 (used for CI deploy reachability)
{
  networking.useDHCP = false;

  networking.interfaces.ens18 = {
    useDHCP = false;
    ipv4.addresses = [
      { address = "128.254.224.230"; prefixLength = 24; }
    ];
  };

  networking.defaultGateway = {
    address = "128.254.224.254";
    interface = "ens18";
  };

  # kresd owns port 53; point the system resolver at it
  networking.nameservers = [ "127.0.0.1" ];
  services.resolved.enable = false;
}
