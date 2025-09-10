# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./blue-light-filter.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  # time.timeZone = "Europe/Kyiv";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "uk_UA.UTF-8";
    LC_IDENTIFICATION = "uk_UA.UTF-8";
    LC_MEASUREMENT = "uk_UA.UTF-8";
    LC_MONETARY = "uk_UA.UTF-8";
    LC_NAME = "uk_UA.UTF-8";
    LC_NUMERIC = "uk_UA.UTF-8";
    LC_PAPER = "uk_UA.UTF-8";
    LC_TELEPHONE = "uk_UA.UTF-8";
    LC_TIME = "uk_UA.UTF-8";
  };

  xdg.mime.enable = true; # This is usually true by default
  xdg.mime.defaultApplications = {
    "text/html" = [ "vivaldi.desktop" ];
    "x-scheme-handler/http" = [ "vivaldi.desktop" ];
    "x-scheme-handler/https" = [ "vivaldi.desktop" ];
  };

  # programs.sway = {
  #   enable = true;
  #   # wrapperFeatures.gtk
  # };

  services.greetd = {
    enable = true;
    # vt = 1;
    settings = {
      default_session = {
        # command = "${pkgs.hyprland}/bin/hyprland";
        command = "${pkgs.sway}/bin/sway";
        user = "nix";
      };
    };
  };

  services.upower = {
    enable = true;
    usePercentageForPolicy = true;
    percentageLow = 40;
    percentageCritical = 35;
    percentageAction = 30;
    criticalPowerAction = "PowerOff";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nix = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.bash;
  };

  users.defaultUserShell = pkgs.bash;

  programs.bash.blesh.enable = true;

  programs.starship.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "nix";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Install firefox.
  programs.firefox.enable = true;

  # users.defaultUserShell = pkgs.zsh;
  # programs.zsh = {
  #   enable = true;
  #   autosuggestions = {enable = true;};
  #   syntaxHighlighting = {enable = true;};
  #   # ohMyZsh = {
  #   #   enable = true;
  #   #   plugins = [
  #   #    "zsh-expand"
  #   #   # {
  #   #   #   name = "zsh-expand";
  #   #   #   src = pkgs.fetchFromGitHub {
  #   #   #     owner = "MenkeTechnologies";
  #   #   #     repo = "zsh-expand.git";
  #   #   #   };
  #   #   # }
  #   #   ];
  #   # };
  # };

  programs.tmux = { enable = true; };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.variables = {
    CLIP_HIST = "/tmp/clipman.json";
    NIXPKGS_ALLOW_UNFREE = 1;
    PATH = "$HOME/.npm/bin:$PATH";
    # XDG_RUNTIME_DIR = "/run/user/$UID";
    # XDG_CURRENT_DESKTOP = "hyprland"; # Helps applications know they're on Sway
    # XDG_SESSION_TYPE = "wayland"; # Explicitly state the session type
  };

  # xdg.portal.enable = pkgs.lib.mkForce false; # Fix vivaldi using portals instead of xdg-open
  # xdg.portal.enable = true;
  xdg.portal = { # for flatpak
    enable = true;
    extraPortals = with pkgs;
      [
        # xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk # Important for GTK applications
      ];
    # config.common.default = [ "hyprland" "gtk" ];
    config.common.default = [ "sway" "gtk" ];
  };

  services.flatpak = { # from nix-flatpak
    enable = true;
    packages =
      [ "app.zen_browser.zen" "com.github.tchx84.Flatseal" "com.viber.Viber" ];
    overrides = {
      "app.zen_browser.zen".Context = {
        filesystems = [ "home" "/tmp" "xdg-config/" "xdg-data/" ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    ### Code
    (python3.withPackages (p: with p; [ yt-dlp curl-cffi ]))
    gnumake # for vim-jsdoc
    bash-language-server
    vscode-langservers-extracted # lsps: css html eslint json markdown
    nodejs
    nodePackages.prettier
    black
    go
    typescript
    typescript-language-server
    lua
    cargo
    rustc
    eww
    ### System
    go-mtpfs # only one mtp tool that works
    xorg.xev # print input codes
    rclone
    lsof
    pulseaudioFull # for pactl: watch-volume
    glib
    socat
    wireplumber
    brightnessctl
    htop
    psmisc # *pstree* for cwd, *killall* also
    udiskie
    ### Media
    mkvtoolnix-cli
    libreoffice-fresh
    vlc
    libva
    vlc-bittorrent
    ### Social
    telegram-desktop
    ### Hardware
    tlp
    acpi
    ### Files
    ntfs3g
    ffmpeg-full
    inotify-tools
    git
    vimiv-qt
    trash-cli
    fd
    git-credential-manager
    ripgrep
    nautilus
    renameutils
    ### Terminals
    alacritty
    ghostty
    ### TUIs
    neovim
    nnn
    bat
    ### Internet
    wget
    # qbittorrent
    transmission_3-gtk
    vivaldi
    dropbox
    ### Deps
    mpv # for nnn previews
    libappindicator # for Dropbox
    libappindicator-gtk3 # for waybar
    libdbusmenu-gtk3 # for waybar
    luarocks-nix # for nvim
    gzip # for treesitter
    gcc # for treesitter. Clang works the same.
    cmake # for nvim supermaven
    marksman # for nvim LSP
    file
    mktemp
    xdotool
    tabbed
    sxiv
    zathura
    nil
    nixfmt-classic
    lua-language-server
    ### Text
    calc
    jq
    diffutils
    translate-shell
    dict
    fzf
    ### WM
    clipman
    grim
    libnotify
    mako # notification daemon for libnotify
    dconf # for dark theme in apps
    # xdg-desktop-portal-hyprland # for flatpak
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr # TODO: for opening files in flatpak zen-browser
    hyprpaper
    wl-clipboard
    wofi
    hyprsunset
    waybar
    i3status-rust
    ### Trash
    # zsh-completions zsh-syntax-highlighting nix-zsh-completions
    # ncurses # for tui app colors
    # gnumake # for bin/make
    #  wget
  ];

  services.dictd = {
    enable = true;
    DBs = [
      pkgs.dictdDBs.wordnet
      # pkgs.dictdDBs.gcide
    ];
  };

  programs.sway = { enable = true; };

  # programs.hyprland = {
  #   enable = true;
  #   withUWSM = true; # for systemd `after = [ "graphical-session.target" ];`
  # };

  programs.npm = {
    enable = true;
    npmrc = "ignore-scripts=true";
  };

  programs.dconf.profiles.user.databases = [{
    settings."org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita-dark"; # Your chosen dark GTK theme
      color-scheme = "prefer-dark"; # For GTK4/Libadwaita apps
    };
  }];

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandlePowerKey = "poweroff";
    HandlePowerKeyLongPress = "sleep";
  };

  fonts = {
    # enableDefaultPackages = true; # TODO remove
    fontDir.enable = true; # TODO remove
    packages = with pkgs;
      [ font-awesome ] ++ builtins.filter lib.attrsets.isDerivation
      (builtins.attrValues pkgs.nerd-fonts);
    fontconfig = { enable = true; };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # NOTE: nixing coz nix runs `systemctl enable` for each one
  systemd.user.services = {
    dropbox-gui = {
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.dropbox}/bin/dropbox 2>/dev/null ";
        Restart = "always";
      };
    };
    dropbox-headless = {
      wantedBy = [ "default.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.dropbox}/bin/dropbox 2>/dev/null ";
        Restart = "always";
        ExecCondition = "if [ -n $WAYLAND_DISPLAY ]; then exit 1; fi";
      };
    };
    udiskie-gui = {
      wantedBy = [ "graphical-session.target" ];
      path = with pkgs; [ bash udiskie alacritty nnn xdg-utils ];
      script = ''
        udiskie --smart-tray | while read l; do 
          mount_dir="$(sed -nr 's/mounted .* on (.*)/\1/p' <<< "$l")"
          if [[ -d "$mount_dir" ]]; then
            alacritty -e bash -c "nnn \"$mount_dir\"; bash"
          fi
        done
      '';
      serviceConfig = { Restart = "always"; };
    };
    udiskie-headless = {
      wantedBy = [ "default.target" ];
      after = [ "graphical-session.target" ];
      path = with pkgs; [ bash udiskie alacritty nnn xdg-utils ];
      script = ''
        udiskie | while read l; do 
          mount_dir="$(sed -nr 's/mounted .* on (.*)/\1/p' <<< "$l")"
          if [[ -d "$mount_dir" ]]; then
            alacritty -e bash -c "nnn \"$mount_dir\"; bash"
          fi
        done
      '';
      serviceConfig = {
        ExecCondition = "if [ -n $WAYLAND_DISPLAY ]; then exit 1; fi";
        Restart = "always";
      };
    };
    clip = {
      wantedBy = [ "graphical-session.target" ];
      path = with pkgs; [ wl-clipboard clipman ];
      script =
        "wl-paste --watch clipman store --max-items=9999 --histpath=${config.environment.variables.CLIP_HIST}";
      serviceConfig = { Restart = "always"; };
    };
  };
  services.udisks2.enable = true; # required for udiskie

  # # services.displayManager.defaultSession = "gnome";
  # services.xserver = {
  #   enable = true;
  #   displayManager = {
  #     gdm = {
  #       enable = true;
  #       # wayland = true;
  #     };
  #   };
  #   xkb = {
  #     layout = "us";
  #     variant = "";
  #   };
  #   # desktopManager.gnome = {
  #   #   enable = true;
  #   #   extraGSettingsOverridePackages = [ pkgs.mutter ];
  #   #   extraGSettingsOverrides = ''
  #   #     [org.gnome.mutter]
  #   #     experimental-features=['scale-monitor-framebuffer']
  #   #       '';
  #   # };
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
