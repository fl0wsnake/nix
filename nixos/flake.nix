{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    zls.url = "github:zigtools/zls/releases/tag/0.16.0";
    zls.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      self,
      nixpkgs,
      nix-flatpak,
      zls,
      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          nix-flatpak.nixosModules.nix-flatpak
          {
            environment.systemPackages = [
              zls.packages.x86_64-linux.zls
            ];
          }
        ];
      };
    };
}
