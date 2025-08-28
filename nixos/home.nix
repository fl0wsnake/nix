{ pkgs, ... }: {
  # imports = [ (import "${home-manager}/nixos") ];

  # home-manager.extraSpecialArgs = [ hy3 ];

  home.stateVersion = "25.05";

  # programs.yt-dlp.enable = true;
  # home.packages = [ (pkgs.python3.withPackages (p: [ p.yt-dlp p.curl-cffi ])) ];

  programs.nnn = {
    enable = true;
    plugins = [ "nnn-fzf" ];
  }

  wayland.windowManager.hyprland = {
    enable = true;
    # plugins = [ pkgs.hyprlandPlugins.hy3 ];
    extraConfig = "source = ~/.config/hypr/config.conf";
  };

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
