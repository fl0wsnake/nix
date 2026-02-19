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
    LC_COLLATE = "C"; # affects all file pickers
    GTK_THEME = "Adwaita:dark"; # affects firefox, gparted etc.
  };
  poweroffGracefully =
    with pkgs;
    writeShellScriptBin "poweroff-gracefully" ''
      ${systemd}/bin/systemd-run -M ${config.environment.sessionVariables.USER}@ --user ${pkgs.sway}/bin/swaymsg '[app_id=.*]kill' # To avoid `restore session` popups in chromium based browsers
      if [ "$(id -u)" -eq 0 ]; then
        ${systemd}/bin/systemd-run --on-active=5s ${systemd}/bin/systemctl poweroff
      else
        sudo ${systemd}/bin/systemctl poweroff
      fi
    '';
  zshAutoNotify = pkgs.fetchFromGitHub {
    owner = "MichaelAquilina";
    repo = "zsh-auto-notify";
    rev = "0.11.1";
    sha256 = "0pr1jab3msn966wzwpi008k0kq05j71v8ml8pcpfs4mbnzic7qfp";
  };
in
{
  nix.settings.auto-optimise-store = true;
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
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  boot.tmp.useTmpfs = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "-d";
  };

  system.autoUpgrade = {
    enable = true;
    dates = "daily";
  };

  nix.optimise.automatic = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = false; # Conflicts with NetworkManager

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

  # # for gnome-network-displays & casting
  # services.xserver.config = ''
  #   Section "Module"
  #     Load "dri2"
  #     Load "dri3"
  #   EndSection
  # '';
  # networking.networkmanager.unmanaged = [
  #   "interface-name:p2p*"
  #   "interface-name:wfd*"
  # ];

  services.hardware.bolt.enable = true;
  # boot.blacklistedKernelModules = [ "nouveau" ]; # might wanna remove these boot entries
  # boot.initrd.kernelModules = [
  #   "thunderbolt"
  # ];
  # boot.kernelModules = [
  #   "nvidia"
  #   "nvidia_uvm"
  # ];
  boot.kernelParams = [
    # "pci=assign-busses"
    # "pci=realloc"
    # "pcie_port_pm=off"
    "nvidia-drm.modeset=1"
  ]; # ikd if needed
  nixpkgs.config = {
    allowUnfree = true; # for Nvidia drivers etc
    # nvidia.acceptLicense = true;
    # cudaCapabilities = [ "6.1" ];
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Helpful for steam and certain drivers
    # extraPackages = with pkgs; [
    #   nvidia-vaapi-driver
    #   vulkan-loader
    #   vulkan-validation-layers
    #   vulkan-tools
    # ];
  }; # needed for ollama to communicate with the driver
  services.xserver.videoDrivers = [ "nvidia" ]; # `Generic PCI device` ->  `Nvidia card`
  hardware.nvidia = {
    modesetting.enable = true;
    # nvidiaPersistenced = true;
    powerManagement.enable = true; # Can cause issues, but saves power
    open = false; # true for Turing+ architechture
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.ollama = {
    enable = true;
    # acceleration = "vulkan"; # late 2025 feature
    package = pkgs.ollama-cuda;

    # 2. Force Vulkan via Environment Variables
    # environmentVariables = {
    #   OLLAMA_VULKAN = "1";
    # };
    # package = pkgs.ollama.override {
    #   acceleration = "cuda";
    #   cudaArches = [ "61" ];
    # };
    # environmentVariables = {
    #   CUDA_VISIBLE_DEVICES = "0";
    # };
  };
  # systemd.services.ollama.serviceConfig = {
  #   # LD_LIBRARY_PATH = "/run/opengl-driver/lib:/run/cudatoolkit/lib";
  #   Environment = "CUDA_VISIBLE_DEVICES=0";
  # };

  zramSwap = {
    enable = true;
    priority = 100;
  };
  services.swapspace.enable = true;

  boot.extraModprobeConfig = ''
    options psmouse elantech_smbus=0
  ''; # 2 for [t480s touchpad issue](https://wiki.archlinux.org/title/Laptop#Elantech)

  # INFO: Enable CUPS to print documents.
  services.printing.enable = true;

  # INFO: Enable sound with pipewire.
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

  # INFO: Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nix = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video" # for eGPU
      "render"
    ];
    shell = pkgs.zsh;
  };
  # INFO: bash's alias expansion isn't good enough
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh.enable = true;
    ohMyZsh.plugins = [ "git" ];
    interactiveShellInit = ''
      source ${zshAutoNotify}/auto-notify.plugin.zsh
    '';
  };

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;

  programs.bash.blesh.enable = true;

  programs.starship.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # INFO: Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "nix";
  # INFO: Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  services.gnome.gnome-keyring.enable = true; # INFO: fix brave being unable to restore encrypted user cookies due to autologin disabling keyring
  security.pam.services.greetd.enableGnomeKeyring = true;
  services.dbus.packages = [ pkgs.gcr ];

  programs.firefox.enable = true;

  programs.tmux = {
    enable = true;
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.10"
  ];

  environment.sessionVariables = sessionVariablesFlatpak // {
    USER = "nix";
    NIX_BUILD_CORES = 0;
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  environment.variables = {
    # ZSH = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
    PATH = [
      "$HOME/.npm/bin"
    ];
  };

  ### PACKAGES
  environment.systemPackages = with pkgs; [
    ### SCREEN CASTING
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-vaapi # This provides the DRI/Hardware link
    gst_all_1.gst-libav # For software H.264/AAC fallback
    gst_all_1.gst-rtsp-server # Often needed for the WFD stream
    gnome-network-displays
    ### MAKE
    libx11
    imlib2Full
    pkg-config
    ### CODE
    gofumpt
    golangci-lint-langserver
    claude-code
    gitkraken
    google-cloud-sdk
    nix-index # to nix-locate `#include <.h>`
    cursor-cli
    clojure-lsp
    zls
    direnv
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
    vscode-langservers-extracted # LSPs: css html eslint json markdown
    nodejs
    nodePackages.prettier
    black
    go
    gopls
    typescript
    typescript-language-server
    lua
    cargo
    rustc
    eww
    ### MEDIA
    shotcut
    kdePackages.kdenlive
    nsxiv
    shotcut
    python313Packages.grip # uses github API
    imagemagick # rotate images from nnn
    gimp3
    mkvtoolnix-cli
    libreoffice-fresh
    vlc
    libva
    vlc-bittorrent
    ### SOCIAL
    viber
    telegram-desktop
    whatsapp-electron
    ### HARDWARE
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
    thunar
    ### TERMINALS
    kitty
    alacritty # kitty has crap scrollback and does not use a -e flag for exec
    ghostty
    ### TUIs
    ascii
    neovim
    nnn
    bat
    ### NETWORK
    (pkgs.brave.override {
      commandLineArgs = [
        "--restore-last-session"
        "--disable-session-crashed-bubble"
      ];
    })
    microsoft-edge
    google-chrome
    nix-search-cli
    wget
    transmission_4-gtk
    vivaldi
    dropbox
    ### DEPS
    mpv # for nnn previews
    libappindicator # for Dropbox
    # libappindicator-gtk3 # for waybar
    # libdbusmenu-gtk3 # for waybar
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
    pup
    jq
    diffutils
    translate-shell
    dict
    fzf
    ### WM/SYSTEM
    hyprpicker # colorpick
    pastel # colorpick
    ripdrag
    cliphist
    efibootmgr # for auto Win reboot
    ventoy
    expect # `unbuffer` to force TTY mode on nix-search to pipe colors to less
    go-mtpfs # only one mtp tool that works
    xev
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
    (pkgs.rofi.override {
      plugins = [ pkgs.rofi-emoji ];
    })
    hyprsunset
    waybar
    i3status-rust
    ### DEV
    imlib2Full # building nsxiv
    ### CUSTOM
    poweroffGracefully
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    # config.common.default = [ "gnome" ]; # for gnome-network-displays TODO remove
  };

  # NOTE From nix-flatpak flake input
  services.flatpak = {
    enable = true;
    packages = [
      "app.zen_browser.zen"
      "com.github.tchx84.Flatseal"
    ];
    overrides = {
      global = {
        Context = {
          sockets = [
            "x11"
            "wayland"
          ]; # Ensure display sockets are available
          filesystems = [ "home" ]; # for user conf
        };
        Environment = sessionVariablesFlatpak;
      };
    };
  };

  services.dbus.enable = true;

  services.dictd = {
    enable = true;
  };

  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        gtk-theme = "Adwaita-dark"; # Your chosen dark GTK theme
        color-scheme = "prefer-dark"; # For GTK4/Libadwaita apps
      };
    }
  ];

  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "5s";
  };
  # INFO: Ever sleep for TIMEOUT max, then poweroff gracefully
  powerManagement.powerDownCommands = ''
    TIMEOUT=43200
    TARGET_TIME=$(( $(date +%s) + $TIMEOUT ))
    echo "$TARGET_TIME" > /run/expected_rtc_wake
    echo 0 > /sys/class/rtc/rtc0/wakealarm
    echo "+$TIMEOUT" > /sys/class/rtc/rtc0/wakealarm
  '';
  powerManagement.resumeCommands = ''
    sudo modprobe -r psmouse && sudo modprobe psmouse
    if [ -f /run/expected_rtc_wake ]; then
      NOW=$(date +%s)
      EXPECTED=$(cat /run/expected_rtc_wake)
      rm /run/expected_rtc_wake
      if [ "$NOW" -ge "$EXPECTED" ]; then
        ${poweroffGracefully}/bin/poweroff-gracefully
      else
        echo "Manual wake-up detected before timeout. Staying awake."
      fi
    fi
    echo 0 > /sys/class/rtc/rtc0/wakealarm
  '';

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandlePowerKey = "poweroff";
    HandlePowerKeyLongPress = "sleep";
  };

  fonts = {
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
    # NOTE: upower signals are not handled by wayland
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

  networking.firewall = {
    trustedInterfaces = [
      "p2p-wl+"
    ]; # for gnome-network-displays
    allowedTCPPorts = [
      22000
      22001 # Syncthing instances
      7236
      7250 # Miracast control
    ];
    allowedUDPPorts = [
      5353 # mDNS
      7236 # Miracast stream
    ];
    allowedUDPPortRanges = [
      {
        from = 32768;
        to = 65535; # for gnome-network-displays
      }
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  }; # for casting

  # NOTE: fix flatpak apps not using xdg-open correctly
  systemd.user.services.xdg-desktop-portal = {
    environment = pkgs.lib.mkForce {
      PATH = "$PATH:/run/current-system/sw/bin:/var/lib/flatpak/exports/bin";
    };
  };

  services.udisks2 = {
    enable = true; # NOTE: required for udiskie
    mountOnMedia = true; # NOTE: otherwise it creates /run/media/$USER without `x` permissions, which doesn't let Transmission download
    settings = {
      "mount_options.conf" = {
        defaults = {
          ntfs_drivers = "ntfs-3g,ntfs3"; # NOTE: fix mounting error
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
