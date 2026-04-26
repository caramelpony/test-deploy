{ ... }:
# Minimal Caddy: plain HTTP on port 80, no TLS, no domain required.
{
  services.caddy = {
    enable = true;

    # Disable auto-HTTPS — test VM has no real domain or cert.
    globalConfig = ''
      auto_https off
    '';

    virtualHosts.":80" = {
      extraConfig = ''
        respond "it worked" 200
      '';
    };
  };
}
