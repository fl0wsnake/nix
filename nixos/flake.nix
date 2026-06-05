{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-flatpak,
      ...
    }:
    let
      system = "x86_64-linux";
      unstable = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      system = "x86_64-linux";
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit unstable; };
        modules = [
          ./configuration.nix
          nix-flatpak.nixosModules.nix-flatpak
        ];
      };
    };
}
