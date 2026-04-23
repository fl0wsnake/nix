{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    zls.url = "github:zigtools/zls/0.16.0";
    zig.url = "github:mitchellh/zig-overlay";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-flatpak,
      zls,
      zig,
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
          {
            environment.systemPackages = [
              zls.packages.x86_64-linux.zls
              zig.packages.x86_64-linux.default
            ];
          }
        ];
      };
    };
}
