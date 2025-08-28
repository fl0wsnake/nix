{
  inputs = {
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    # hy3 = {
    #   url =
    #     "github:outfoxxed/hy3"; # "github:outfoxxed/hy3" to follow the development branch. (you may encounter issues if you dont do the same for hyprland)
    # };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs, nix-flatpak, ... }: {
    # homeConfigurations."nix" = home-manager.lib.homeManagerConfiguration {
    #   pkgs = nixpkgs.legacyPackages.x86_64-linux;
    #   modules = [ ./home.nix ];
    # };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        {
          # home-manager.useGlobalPkgs = true;
          # home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.nix = import ./home.nix;
          # home-manager.extraSpecialArgs = { inherit nixpkgs; };

          # Optionally, use home-manager.extraSpecialArgs to pass
          # arguments to home.nix
        }

        # {
        #   wayland.windowManager.hyprland = {
        #     enable = true;
        #     plugins = [ hy3.packages.x86_64-linux.hy3 ];
        #   };
        # }
      ];
    };
  };
}

