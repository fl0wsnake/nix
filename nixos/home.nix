{ pkgs, ... }: {
  # imports = [ (import "${home-manager}/nixos") ];

  # home-manager.extraSpecialArgs = [ hy3 ];

  home.stateVersion = "25.05";

  # programs.yt-dlp.enable = true;
  # home.packages = [ (pkgs.python3.withPackages (p: [ p.yt-dlp p.curl-cffi ])) ];

  # programs.nnn = { TODO
  #   enable = true;
  # };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = "source = ~/.config/hypr/config.conf";
  };

  programs.home-manager.packages = [ nodePackages.npm-package-name ];

  # https://github.com/outfoxxed/hy3

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  # programs.git = {
  #   enable = true;
  #   userName = "fl0wsnake";
  #   userEmail = "lastthursdayist@gmail.com";
  #   extraConfig = {
  #     credential = {
  #       helper = "/run/current-system/sw/bin/git-credential-manager";
  #       credential."https://dev.azure.com".useHttpPath = true;
  #     };
  #   };
  # };
}
