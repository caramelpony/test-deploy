{ config, pkgs, ... }:
# Tailscale — auth only, no subnet/exit-node advertising for the test VM.
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [ "--accept-dns=false" ];
  };

  systemd.services.tailscale-auth = {
    description = "Tailscale initial authentication";
    after = [ "tailscaled.service" "network-online.target" "sops-nix.service" ];
    wants = [ "tailscaled.service" "sops-nix.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -euo pipefail
      if ${pkgs.tailscale}/bin/tailscale status --json \
          | ${pkgs.jq}/bin/jq -e '.BackendState == "Running"' > /dev/null 2>&1; then
        echo "Tailscale already authenticated, skipping"
        exit 0
      fi

      AUTH_KEY=$(cat ${config.sops.secrets.tailscale-auth-key.path})
      ${pkgs.tailscale}/bin/tailscale up \
        --authkey="$AUTH_KEY" \
        --accept-dns=false \
        --hostname=test-vm
    '';
  };
}
