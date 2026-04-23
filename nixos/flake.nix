{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    zls.url = "github:zigtools/zls/0.16.0";
    zls.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, nix-flatpak, zls, ... }:
    let
      system = "x86_64-linux";
      unstable = import nixpkgs-unstable { inherit system; };
    in {
      system = "x86_64-linux";
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit unstable; };
        modules = [
          ./configuration.nix
          nix-flatpak.nixosModules.nix-flatpak
          { environment.systemPackages = [ zls.packages.x86_64-linux.zls ]; }
        ];
      };
    };
}
