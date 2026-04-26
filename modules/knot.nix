{ ... }:
{
  services.kresd = {
    enable = true;
    listenPlain = [
      "127.0.0.1:53"
      "128.254.224.230:53"
    ];
    extraConfig = ''
      policy.add(policy.all(policy.FORWARD('1.1.1.1')))
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
