# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:

let
  sessionVariablesFlatpak = {
    GTK_THEME = "Adwaita:dark"; # affects firefox, zen, gparted etc.
  };
in
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

  # boot.tmp = {
  #   # cleanOnBoot = true;
  #   useTmpfs = true;
  # };
  boot.tmp.useTmpfs = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
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
        command = "${pkgs.sway}/bin/sway --unsupported-gpu"; # Using nvidia drivers for ollama, for graphics will need nouveau
        user = "nix";
      };
    };
  };

  services.hardware.bolt.enable = true;
  # boot.kernelParams = [
  #   "pci=realloc"
  #   "pci=assign-busses"
  #   "hpbussize=0x33"
  #   "nvidia-drm.modeset=1"
  # ];
  services.xserver.videoDrivers = [ "nvidia" ]; # `Generic PCI device` ->  `Nvidia card`
  hardware.graphics.enable = true; # needed for ollama to communicate with the driver
  hardware.nvidia = {
    open = false; # true for Turing+ architechture
    # powerManagement.enable = true; # Can cause issues, but saves power
    modesetting.enable = false; # Required for Wayland, so no
    prime = {
      offload.enable = true;
      intelBusId = "PCI:00:02:0";
      nvidiaBusId = "PCI:07:00:0";
      # sync.enable = true;
      #   allowExternalGpu = true;
      #   # Find these using `lspci` (e.g., "00:02.0" -> "PCI:0:2:0")
      #   # nvidiaBusId = "PCI:1:0:0"; # Your eGPU Bus ID
    };
  };
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    package = pkgs.ollama.override {
      acceleration = "cuda";
      cudaArches = [ "61" ];
    };
    # environmentVariables = {
    #   CUDA_VISIBLE_DEVICES = "0";
    # };
  };
  systemd.services.ollama.serviceConfig = {
    LD_LIBRARY_PATH = "/run/opengl-driver/lib:/run/cudatoolkit/lib";
  };

  services.swapspace.enable = true;

  boot.extraModprobeConfig = ''
    options psmouse elantech_smbus=0
  ''; # [t480s touchpad issue](https://wiki.archlinux.org/title/Laptop#Elantech)

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
      "video" # for egpu
      "render"
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

  nixpkgs.config.allowUnfree = true; # for Nvidia drivers etc

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  # From nix-flatpak flake input
  services.flatpak = {
    enable = true;
    packages = [
      "app.zen_browser.zen"
      "com.github.tchx84.Flatseal"
      "com.viber.Viber"
    ];
    overrides = {
      global = {
        Context = {
          sockets = [
            "x11"
            "wayland"
          ]; # Ensure display sockets are available
          filesystems = [ "home" ]; # for zen user conf
        };
        Environment = sessionVariablesFlatpak;
      };
    };
  };

  services.dbus.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.07"
    # "qtwebengine-5.15.19" # for whatsie
  ];

  environment.sessionVariables = sessionVariablesFlatpak // {
    # PKG_CONFIG_PATH = lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
    #   pkgs.imlib2
    #   pkgs.libx11
    # ];
    C_INCLUDE_PATH =
      with pkgs;
      lib.makeSearchPathOutput "dev" "include" [
        xorgproto # for nsxiv
        z88dk
        libxft
        libexif
        imlib2
        libx11
      ];
    PATH = "$HOME/.npm/bin:$PATH";
    USER = "nix";
    NIXPKGS_ALLOW_UNFREE = 1;
    NIXPKGS_ALLOW_INSECURE = 1; # packages become insecure from occasionally. This is it save time.
    NIX_BUILD_CORES = 0;
  };

  environment.systemPackages = with pkgs; [
    ### MAKE
    libx11
    imlib2Full
    pkg-config
    ### CODE
    aider-chat
    shfmt
    cloc
    typescript-language-server
    deno
    basedpyright
    ruff
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
    ### MEDIA
    nsxiv
    pinta # for cropping, clone stamp, all shortcuts
    shotcut
    xfce.thunar
    python313Packages.grip # uses github API
    imagemagick # rotate images from nnn
    gimp3
    mkvtoolnix-cli
    libreoffice-fresh
    vlc
    libva
    vlc-bittorrent
    ### SOCIAL
    telegram-desktop
    whatsapp-electron
    ### HARDWARE
    config.boot.kernelPackages.nvidia_x11
    pciutils # for tb3/egpu
    usbutils
    tlp
    acpi
    ### FILESYSTEM
    exfatprogs # for disk formatting
    exfat # for disk formatting
    jujutsu
    rar
    unrar
    zip
    unzip
    syncthing
    syncthingtray
    ntfs3g
    ffmpeg-full
    inotify-tools
    tig
    git
    vimiv-qt
    clang-tools
    trash-cli
    fd
    git-credential-manager
    ripgrep
    nautilus
    ### TERMINALS
    kitty
    alacritty # kitty has crap scrollback and does not use a -e flag for exec
    ghostty
    ### TUIs
    neovim
    nnn
    bat
    ### NETWORK
    # chromium
    nix-search-cli
    wget
    transmission_4-gtk
    vivaldi
    dropbox
    ### DEPS
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
    zathura
    nixd
    nixfmt
    lua-language-server
    ### TEXT/LANGUAGE/PARSING
    tesseract
    python313Packages.langdetect
    piper-tts
    calc
    jq
    diffutils
    translate-shell
    dict
    fzf
    ### WM/SYSTEM
    vicinae
    batsignal
    efibootmgr # for auto Win reboot
    ventoy
    expect # `unbuffer` to force TTY mode on nix-search to pipe colors to less
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
    wlsunset
    grim
    flameshot
    libnotify
    mako # notification daemon for libnotify
    pango # for mako
    dconf # for dark theme in apps
    wl-clipboard
    rofi
    hyprsunset
    waybar
    i3status-rust
    # DEV
    imlib2Full # building nsxiv
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

  powerManagement.resumeCommands = ''
    sudo modprobe -r psmouse && sudo modprobe psmouse
  '';

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

  hardware.bluetooth.enable = true;
  services.blueman.enable = true; # Enables the Blueman graphical tool

  # NOTE: nixing coz nix runs `systemctl enable` for each one
  systemd.user.services = {
    # upower signals are not handled by wayland
    batsignal = {
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.batsignal}/bin/batsignal -w 40 -c 30 -d 20 -D 'shutdown now'";
        Restart = "always";
      };
    };
    tray-ready = {
      wantedBy = [ "default.target" ];
      after = [ "graphical-session.target" ];
      requires = [ "graphical-session.target" ];
      path = with pkgs; [ procps ];
      script = ''
        if [ -n $DISPLAY ]; then
          while ! pkill -0 eww >/dev/null; do
            sleep 1;
          done
        fi
      '';
      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };
    };
    dropbox = {
      wantedBy = [ "default.target" ];
      after = [ "tray-ready.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.dropbox}/bin/dropbox";
        Restart = "always";
      };
    };
    udiskie = {
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.udiskie}/bin/udiskie";
        Restart = "always";
      };
    };
    wlsunset = {
      wantedBy = [ "graphical-session.target" ];
      requires = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.wlsunset}/bin/wlsunset -S 4:30 -s 20:00;";
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
    trash-empty = {
      wantedBy = [ "timers.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.trash-cli}/bin/trash-empty 28";
      };
    };
  };
  systemd.user.timers = {
    trash-empty = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    # Syncthing discovery
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
    mountOnMedia = true; # otherwise it creates /run/media/$USER without `x` permissions, which doesn't let Transmission download
    settings = {
      "mount_options.conf" = {
        defaults = {
          ntfs_drivers = "ntfs-3g,ntfs3"; # fix mounting error
        };
      };
    };
  };

  users.users.transmission = {
    group = "users";
    isSystemUser = true;
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
