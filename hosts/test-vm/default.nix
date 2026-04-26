{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./networking.nix
  ];

  system.stateVersion = "24.11";
  networking.hostName = "test-vm";

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # SeaBIOS / BIOS boot — no EFI on this VM
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
    hostKeys = [
      { type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; }
    ];
  };

  users.users.caramel = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL3Lep+c7+DVsiDROabc/BMY/cFbvuQ9kyGl/S8P2z5P caramel@caramel.dog"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  # ── SOPS secrets ─────────────────────────────────────────────────────────
  # age.key is planted via nixos-anywhere --extra-files before nixos-install runs.
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/age.key";
    secrets = {
      tailscale-auth-key = { owner = "root"; mode = "0400"; };
    };
  };

  # ── Firewall ─────────────────────────────────────────────────────────────
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 ];
    allowedUDPPorts = [ 41641 ];  # Tailscale
  };

  environment.systemPackages = with pkgs; [ vim curl jq ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
