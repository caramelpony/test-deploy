{
  description = "NixOS test VM — dry-run for nl-ams-1 deploy flow";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, sops-nix, ... }:
  let
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"
    ];
  in
  {
    nixosConfigurations.test-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
        ./hosts/test-vm
        ./modules/caddy.nix
        ./modules/tailscale.nix
        ./modules/knot.nix
      ];
    };

    # Run `nix develop ./test#` from the repo root to get all bootstrap tools.
    devShells = forAllSystems (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in {
        default = pkgs.mkShell {
          name = "test-vm-ops";
          packages = with pkgs; [
            nixos-anywhere
            sops
            age
            ssh-to-age
          ];
          shellHook = ''
            echo "test-vm ops shell — bootstrap tools ready"
            echo "  1. test/scripts/bootstrap-sops.sh"
            echo "  2. test/scripts/deploy.sh"
          '';
        };
      });
  };
}
