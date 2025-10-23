# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 30d";
  };

  system.autoUpgrade = {
    enable = true;
    dates = "daily";
  };

  nix.optimise.automatic = true;

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

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.sway}/bin/sway";
        user = "nix";
      };
    };
  };

  services.upower = {
    enable = true;
    usePercentageForPolicy = true;
    percentageLow = 40;
    percentageCritical = 30;
    percentageAction = 20;
    criticalPowerAction = "PowerOff";
  };
  security.polkit = {
    # for criticalPowerAction
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.upower.hibernate" ||
          action.id == "org.freedesktop.upower.suspend" ||
          action.id == "org.freedesktop.login1.power-off" ||
          action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
          action.id == "org.freedesktop.login1.reboot" ||
          action.id == "org.freedesktop.login1.reboot-multiple-sessions") {
          if (subject.isInGroup("users") || subject.isInGroup("wheel") || subject.isInGroup("sudo")) {
            return polkit.Result.YES;
          }
        }
      });
    '';
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true; # Required for low-latency audio
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nix = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };
  # bash's alias expansion isn't good enough
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

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

  programs.tmux = {
    enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    PATH = "$HOME/.npm/bin:$PATH";
    USER = "nix";
    CLIP_HIST = "/tmp/clipman.json";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  xdg.mime.defaultApplications = {
    # "application/vnd.ms-excel" = [];
    #
    # "video/x-matroska" = [];
    # "video/x-msvideo" = [];
    # "video/webm" = [];
    # "video/mp4" = [];
    # "video/3gpp" = [];
    # "application/octet-stream" = [];
    #
    # "image/png" = [];
    # "image/jpeg" = [];
    # "image/bmp" = [];
    #
    # "application/pdf" = [];
    #
    "x-scheme-handler/http" = [ "app.zen_browser.zen.desktop" ];
    "x-scheme-handler/https" = [ "app.zen_browser.zen.desktop" ];
    "text/html" = [ "app.zen_browser.zen.desktop" ];
    "x-scheme-handler/about" = [ "app.zen_browser.zen.desktop" ];
    "x-scheme-handler/unknown" = [ "app.zen_browser.zen.desktop" ];
    #
    # "application/x-bittorrent" = [];
    # "x-scheme-handler/magnet" = [];
    #
    # "x-scheme-handler/tg" = [];
    # "x-scheme-handler/tonsite" = [];
    #
    # "x-scheme-handler/viber" = [];
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  services.flatpak = {
    # from nix-flatpak
    enable = true;
    packages = [
      "app.zen_browser.zen"
      "com.github.tchx84.Flatseal"
      "com.viber.Viber"
    ];
    overrides = {
      global = {
        Context.filesystems = [ "home" ]; # for zen user conf
      };
    };
  };

  services.dbus.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.05"
  ];

  environment.systemPackages = with pkgs; [
    efibootmgr
    grub2
    ventoy
    lf
    os-prober
    ### Code
    tree-sitter
    zig
    (python3.withPackages (
      p: with p; [
        yt-dlp
        curl-cffi
      ]
    ))
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
    expect # for unbuffering vimiv | wl-copy
    go-mtpfs # only one mtp tool that works
    xorg.xev # print input codes
    rclone
    lsof
    pulseaudioFull # for pactl: watch-volume
    pavucontrol # for combining audio sinks (2 bluetooth earpods)
    glib
    socat
    wireplumber
    brightnessctl
    htop
    udiskie
    ### Media
    xfce.thunar
    python313Packages.grip # uses github API
    imagemagick # rotate images from nnn
    gimp3
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
    syncthing
    syncthingtray
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
    alacritty # kitty has crap scrollback and does not use a -e flag for exec
    ghostty
    ### TUIs
    neovim
    nnn
    bat
    ### Internet
    chromium
    nix-search-cli
    onedrive
    wget
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
    nixfmt
    lua-language-server
    ### Text
    calc
    jq
    diffutils
    translate-shell
    dict
    fzf
    ### WM
    wlsunset
    clipman
    grim
    libnotify
    mako # notification daemon for libnotify
    pango # for mako
    dconf # for dark theme in apps
    hyprpaper
    wl-clipboard
    wofi
    hyprsunset
    waybar
    i3status-rust
  ];

  services.dictd = {
    enable = true;
    DBs = [
      pkgs.dictdDBs.wordnet
      # pkgs.dictdDBs.gcide
    ];
  };

  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        gtk-theme = "Adwaita-dark"; # Your chosen dark GTK theme
        color-scheme = "prefer-dark"; # For GTK4/Libadwaita apps
      };
    }
  ];

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandlePowerKey = "poweroff";
    HandlePowerKeyLongPress = "sleep";
  };

  fonts = {
    # fontDir.enable = true; # TODO remove if it didn't break anything
    packages =
      with pkgs;
      [ font-awesome ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
    fontconfig = {
      enable = true;
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true; # Enables the Blueman graphical tool

  # NOTE: nixing coz nix runs `systemctl enable` for each one
  systemd.user.services = {
    dropbox = {
      wantedBy = [ "graphical-session.target" ];
      script = ''
        while ! ${pkgs.procps}/bin/pgrep eww; do
          sleep 1;
        done
        ${pkgs.dropbox}/bin/dropbox
      '';
      serviceConfig = {
        Restart = "always";
      };
    };
    udiskie = {
      wantedBy = [ "graphical-session.target" ];
      path = with pkgs; [
        procps
        bash
        udiskie
        alacritty
        nnn
        xdg-utils
      ];
      script = ''
        . /home/${config.environment.sessionVariables.USER}/.config/nnn/config
        while ! pgrep eww; do
          sleep 1;
        done
        udiskie --smart-tray | while read l; do 
          mount_dir="$(sed -nr 's/mounted .* on (.*)/\1/p' <<< "$l")"
          if [[ -d "$mount_dir" ]]; then
            alacritty -e bash -c "nnn \"$mount_dir\"; bash"
          fi
        done
      '';
      serviceConfig = {
        Restart = "always";
      };
    };
    onedrive = {
      wantedBy = [ "default.target" ];
      path = [ pkgs.onedrive ];
      script = "onedrive --monitor";
      serviceConfig = {
        Restart = "always";
      };
    };
    clip = {
      wantedBy = [ "graphical-session.target" ];
      path = with pkgs; [
        wl-clipboard
        clipman
      ];
      script = "wl-paste --watch clipman store --max-items=9999 --histpath=${config.environment.sessionVariables.CLIP_HIST}";
      serviceConfig = {
        Restart = "always";
      };
    };
    wlsunset = {
      wantedBy = [ "graphical-session.target" ];
      path = with pkgs; [ wlsunset ];
      script = "wlsunset -S 4:30 -s 20:00";
      serviceConfig = {
        Restart = "always";
      };
    };
    syncthing-1 = {
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = with config.environment.sessionVariables; {
        ExecStart = ''
          ${pkgs.syncthing}/bin/syncthing --no-browser --no-restart --logflags=0 \
            --gui-address '0.0.0.0:8384' \
            --home '/home/${USER}/.config/syncthing-1'
        '';
      };
    };
    syncthing-2 = {
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = with config.environment.sessionVariables; {
        ExecStart = ''
          ${pkgs.syncthing}/bin/syncthing --no-browser --no-restart --logflags=0 \
            --gui-address '0.0.0.0:8385' \
            --home '/home/${USER}/.config/syncthing-2'
        '';
      };
    };
  };
  networking.firewall.allowedTCPPorts = [
    8384
    8385
    22000
    22001
  ];

  # fix flatpak apps not using xdg-open correctly
  systemd.user.services.xdg-desktop-portal = {
    # NOTE: conflicting definition does not include xdg-open nor app.zen_browser.zen, setting `after` to `default.target` didn't help
    environment = pkgs.lib.mkForce {
      PATH = "$PATH:/run/current-system/sw/bin:/var/lib/flatpak/exports/bin";
    };
  };

  services.udisks2 = {
    enable = true; # required for udiskie
    settings = {
      "mount_options.conf" = {
        defaults = {
          ntfs_drivers = "ntfs-3g,ntfs3"; # fix error mounting ntfs formatted `WD My Passport`
        };
      };
    };
  };

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
