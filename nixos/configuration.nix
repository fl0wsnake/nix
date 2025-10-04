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

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # for flatpak dbus interaction
        command = ''
          bash -c 'eval $(dbus-launch --sh-syntax --exit-with-session)
          export DBUS_SESSION_BUS_ADDRESS
          exec sway'
        '';
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nix = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    # bash's alias expansion isn't good enough
    enable = true;
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

  environment.variables = {
    USER = "nix";
    CLIP_HIST = "/tmp/clipman.json";
    NIXPKGS_ALLOW_UNFREE = 1;
    PATH = "$HOME/.npm/bin:$PATH";
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  services.flatpak = {
    # from nix-flatpak
    enable = true;
    packages = [
      "app.zen_browser.zen"
      "com.github.tchx84.Flatseal"
      "com.viber.Viber"
    ];
  };

  services.dbus.enable = true;

  environment.systemPackages = with pkgs; [
    os-prober
    ### Code
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
    alacritty
    ghostty
    ### TUIs
    neovim
    nnn
    bat
    ### Internet
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

  programs.npm = {
    enable = true;
    npmrc = "ignore-scripts=true";
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
    # enableDefaultPackages = true; # TODO remove
    fontDir.enable = true; # TODO remove
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
    dropbox-headless = {
      wantedBy = [ "default.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.dropbox}/bin/dropbox 2>/dev/null ";
        Restart = "always";
        ExecCondition = "/bin/sh -c 'if [ -n \"\${WAYLAND_DISPLAY}\" ]; then exit 1; fi'";

      };
    };
    onedrive = {
      wantedBy = [ "default.target" ];
      path = [pkgs.onedrive];
      script = "onedrive --monitor";
      serviceConfig = {
        Restart = "always";
      };
    };
    udiskie-headless = {
      wantedBy = [ "default.target" ];
      after = [ "graphical-session.target" ];
      path = with pkgs; [
        bash
        udiskie
        alacritty
        nnn
        xdg-utils
      ];
      script = ''
        udiskie | while read l; do 
          mount_dir="$(sed -nr 's/mounted .* on (.*)/\1/p' <<< "$l")"
          if [[ -d "$mount_dir" ]]; then
            alacritty -e bash -c "nnn \"$mount_dir\"; bash"
          fi
        done
      '';
      serviceConfig = {
        ExecCondition = "/bin/sh -c 'if [ -n \"\${WAYLAND_DISPLAY}\" ]; then exit 1; fi'";
        Restart = "always";
      };
    };
    clip = {
      wantedBy = [ "graphical-session.target" ];
      path = with pkgs; [
        wl-clipboard
        clipman
      ];
      script = "wl-paste --watch clipman store --max-items=9999 --histpath=${config.environment.variables.CLIP_HIST}";
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
      serviceConfig = with config.environment.variables; {
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
      serviceConfig = with config.environment.variables; {
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

  services.udisks2 = {
    enable = true; # required for udiskie
    settings = {
      "mount_options.conf" = {
        defaults = {
          ntfs_drivers = "ntfs-3g,ntfs3"; # fix error mounting my ntfs formatted `WD My Passport`
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
