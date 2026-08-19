# NOTE: fix brave being unable to restore encrypted user cookies due to autologin disabling keyring. The fix is unreliable as long as autologin is enabled because I may still open brave before I unlock the keyring, which makes brave delete all user cookies! The easiest solution is just disabling brave dependance on the keyring by using plaintext storage.
# services.gnome.gnome-keyring.enable = true;
# security.pam.services.greetd.enableGnomeKeyring = true;
# services.dbus.packages = [ pkgs.gcr ];

{
  config,
  pkgs,
  unstable,
  lib,
  ...
}:

let
  envFlatpak = {
    LC_COLLATE = "C"; # Affects all file pickers; Should be default, because:
    # LC_COLLATE= ls # no way to put names at very start/end:
    # ~!_0-9 -> ~!_a-z -> ~!_A-Z
    # LC_COLLATE=C ls # yes way
    # ! -> _1Aa -> ~
    GTK_THEME = "Adwaita:dark"; # affects firefox, gparted etc.
  };
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
  boot.loader.timeout = 1;

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

  networking.hostName = "nixos";

  # INFO Cause wpa_supplicant takes minutes to wake up; iwd, seconds
  networking.wireless.enable = false;
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # services.hardware.bolt.enable = true;
  # hardware.graphics = {
  #   enable = true;
  #   enable32Bit = true; # Helpful for steam and certain drivers
  # }; # needed for ollama to communicate with the driver
  # services.xserver.videoDrivers =
  #   [ "nvidia" ]; # `Generic PCI device` ->  `Nvidia card`
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   powerManagement.enable = true; # Can cause issues, but saves power
  #   open = false; # true for Turing+ architechture
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };

  zramSwap = {
    enable = true;
    priority = 100;
  };
  services.swapspace.enable = true;

  boot.extraModprobeConfig = ''
    options psmouse elantech_smbus=0
  ''; # 2 for [t480s touchpad issue](https://wiki.archlinux.org/title/Laptop#Elantech)

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
      "qbittorrent"
      "transmission" # fix transmission hanging when downloading to a udiskie mount
      "networkmanager"
      "wheel"
      "video" # for eGPU
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
    interactiveShellInit = ''
      source ${zshAutoNotify}/auto-notify.plugin.zsh
    '';
  };

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;

  programs.bash.blesh.enable = true;

  programs.starship.enable = true;

  programs.nix-ld.enable = true; # for cursor install script

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin = {
    enable = true;
    user = "nix";
  };
  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
  };

  programs.firefox.enable = true;

  programs.tmux = {
    enable = true;
  };

  nixpkgs.config.permittedInsecurePackages = [ "ventoy-1.1.12" ];
  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.variables = envFlatpak // {
  };

  environment.sessionVariables = rec {
    ### NIX
    USER = "nix";
    NIX_BUILD_CORES = 0;
    NIXPKGS_ALLOW_UNFREE = 1;
    ### DEFAULT APPS
    SHELL_COMM = "zsh"; # $SHELL is defined by nixos
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
    EXPLORER = "nnn";
    TERMINAL = "alacritty";
    BROWSER = "brave";
    ### SYNC
    SYNC = "$HOME/Syncthing";
    SCRIPTS_SYNC = "${SYNC}/Data/.config/scripts";
    WIKI = "${SYNC}/Data/Wiki";
    CAMERA = "${SYNC}/DCIM/Camera";
    SCREENSHOTS = "${SYNC}/DCIM/Screenshots";
    ### DIRS
    RICE = "$HOME/.config/nixos-rice";
    SCRIPTS = "$HOME/.config/scripts";
    SCRIPTS_SWAY = "$HOME/.config/sway/scripts";
    SYNC_MOBILE = "$HOME/OneDrive";
    ### OPTS
    # FZF_COLORS = "hl:33,hl+:33";
    FZF_DEFAULT_OPTS = "--color hl:33,hl+:33 --ansi --history=/tmp/.fzf-history --bind=ctrl-d:page-down --bind=ctrl-u:page-up";
    GCM_CREDENTIAL_STORE = "plaintext";
    GREP_COLORS = "always";
    GRIM_DEFAULT_DIR = "${SCREENSHOTS}";
    SXIV_SEL = "/tmp/.nsxiv.sel";
    VIMIV_TAGFILE = "$HOME/.local/share/vimiv/tags/0";
    ZIG_GLOBAL_CACHE_DIR = "$HOME/.cache/zig";
    # GDK_SCALE="1.5"; # Gnome only supports non-fractional scaling by default. "2" is too much for 2560x1440 and "1" is too little.
    # QT_SCALE_FACTOR="1.5";
    ### KITTY
    TMPDIR = "/tmp";
    ### BASH
    PROMPT_COMMAND = "history -a; history -n; $PROMPT_COMMAND";
    HISTSIZE = "100000";
    HISTFILESIZE = "100000";
    HISTCONTROL = "ignoredups:erasedups";
    ### ZSH
    ZDOTDIR = "$HOME/.config/zsh";
    SAVEHIST = "${HISTFILESIZE}";
    ZSH_CUSTOM = "$HOME/.config/zsh/oh-my-zsh/custom";
    AUTO_NOTIFY_THRESHOLD = 1;
    AUTO_NOTIFY_EXPIRE_TIME = 2500;
    AUTO_NOTIFY_TITLE = "%exit_code";
    AUTO_NOTIFY_BODY = "%command";
    ### CODE
    GOTRACEBACK = "all"; # may be too verbose
    RUST_BACKTRACE = 1;
    ### NNN
    NNN_COMM = "nnn;. /tmp/.nnn.lastd"; # needed by wcwd script
    ### [nnn](https://github.com/jarun/nnn)
    NNN_TMPFILE = "/tmp/.nnn.lastd";
    NNN_SCOPE = 1;
    NNN_USE_EDITOR = 1;
    NNN_TRASH = 1;
    NNN_OPTS = "rHRAJxE";
    NNN_ORDER = "t:$HOME/Syncthing/0Phone/Camera;t:$HOME/.local/share/Trash/files;t:$HOME/.local/share/Trash/info;t:$HOME/Downloads;t:/tmp;";
    NNN_FIFO = "/tmp/.nnn.fifo";
    NNN_SEL = "/tmp/.nnn.sel";
    # [plugins](https://github.com/jarun/nnn/tree/master/plugins#nnn-plugins)
    ### NNN_PIPE takes full paths only
    NNN_PLUG = ''
      ;:preview-tui;
      <:!mogrify -rotate -90 \"\$PWD/\$nnn\"*;
      >:!mogrify -rotate 90 \"\$PWD/\$nnn\"*;
      D:diffs;
      F:!file=\$(${SCRIPTS}/fuzzy-ignored) && echo -n \"0c\$file\" >\$NNN_PIPE*;
      Y:!wl-copy --type \$(file -b --mime-type \$nnn) <\$nnn*;
      a:!file=\$(${SCRIPTS}/fuzzy-home) && echo -n \"0c\$file\" >\$NNN_PIPE*;
      d:!dir=&& read -ep 'mkdir -p ' dir && mkdir -p \"\$dir\" && printf '0c%s' \"\$(realpath \"\$dir\")\" >\$NNN_PIPE*;
      e:preview-tabbed;
      f:!file=\$(${SCRIPTS}/fuzzy) && echo -n \"0c\$file\" >\$NNN_PIPE*;
      m:mtpmount;
      n:!nautilus . &*;
      p:!printf '0c%s' \"\$(wl-paste | sed 's|^~|$HOME|')\" >\$NNN_PIPE*;
      s:!echo -n>$NNN_SEL*;
      t:!file=&& read -ep 'touch ' file && touch \"\$file\"*;
      v:!${SCRIPTS}/iv-paste*;
      y:!printf '%s' \"\$PWD/\$nnn\" | sed 's|^$HOME|~|' | wl-copy*;
    '';
    NNN_BMS = ''
      D:${SYNC}/Data;
      r:$HOME/Dropbox;
      S:${SCREENSHOTS};
      T:$HOME/.local/share/Trash/files;
      W:${WIKI};
      c:${CAMERA};
      d:$HOME/Downloads;
      l:${SYNC}/Large;
      m:/run/media/$USER;
      n:${SYNC}/Data/nsfw;
      p:$HOME/Pictures;
      s:${SYNC};
      t:/tmp;
      h:$HOME/Syncthing/Data/Health;
      w:$HOME/WS;
    '';
    PATH = [
      # INFO: these binaries can be a part of this config, hence defining their paths here. Rest goes
      "$HOME/.bun/bin"
      "$HOME/.npm/bin"
      "$HOME/.local/bin"
      "${SCRIPTS}"
    ];
  };

  ### PACKAGES
  environment.systemPackages = with pkgs; [
    ### CODE
    vscode
    just
    rust-bindgen
    pkg-config # May or may not be needed globally
    # pkgconf # INFO to find needed C packages for zig
    zig_0_15
    zls_0_15
    bubblewrap # for codex
    golangci-lint
    gofumpt
    gitkraken
    google-cloud-sdk
    nix-index # to nix-locate `#include <.h>`
    clojure-lsp
    unstable.rust-analyzer # fix creating /src/target
    rustfmt
    direnv
    aider-chat
    shfmt
    cloc
    typescript-language-server
    deno
    basedpyright
    ruff
    tree-sitter
    yt-dlp
    gnumake # for vim-jsdoc
    bash-language-server
    vscode-langservers-extracted # LSPs: css html eslint json markdown
    nodejs
    typescript # for ts_ls
    typescript-language-server # for ts_ls
    bun
    unstable.prettier
    black
    go
    gopls
    lua5_1
    cargo
    rustc
    eww
    sysstat
    ### MEDIA
    losslesscut-bin
    rclip
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
    zapzap
    ### HARDWARE
    pciutils # for tb3/egpu
    usbutils
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
    git
    delta
    lazygit
    vimiv-qt
    clang-tools
    trash-cli
    fd
    gh
    git-credential-manager
    ripgrep
    nautilus
    ### TERMINALS
    kitty
    alacritty # kitty has crap scrollback and does not use a -e flag for exec
    ghostty
    ### TUIs
    ascii
    neovim
    nnn
    moreutils # vidir for nnn
    bat
    ### NETWORK
    totp-cli
    (brave.override {
      commandLineArgs = [
        "--password-store=basic" # otherwise uses keyring, which is unlocked via password, which doesn't happen with autologin, making brave drop user sessions.
      ];
    })
    transmission_4
    qbittorrent
    microsoft-edge
    google-chrome
    nix-search-cli
    wget
    vivaldi
    dropbox
    ### DEPS
    chromium # for puppeteer
    mpv # for nnn previews
    libappindicator # for Dropbox
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
    batsignal
    awww
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
    (pkgs.rofi.override { plugins = [ pkgs.rofi-emoji ]; })
    waybar
    i3status-rust
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
  ];

  services.qbittorrent = {
    group = "users";
    user = "nix";
  };
  programs.fuse.userAllowOther = true;
  systemd.services.qbittorrent.serviceConfig.PrivateMounts = false;
  systemd.services.qbittorrent.serviceConfig.ReadWritePaths = [ "/media/My Passport" ];
  systemd.services.qbittorrent.serviceConfig.BindPaths = [ "/media/My Passport" ];

  # programs.nix-ld.enable = true; # Allows pip to work

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    # config.common.default = [ "gnome" ]; # for gnome-network-displays TODO remove
  };

  # INFO From nix-flatpak flake input
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
        Environment = envFlatpak;
      };
    };
  };

  services.dbus.enable = true;

  services.geoclue2.enable = true; # INFO for automatic tz
  services.automatic-timezoned.enable = true; # INFO works

  services.dictd = {
    enable = true;
  };

  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        gtk-theme = "Adwaita-dark";
        color-scheme = "prefer-dark"; # For GTK4/Libadwaita apps
      };
    }
  ];

  # systemd.settings.Manager = {
  #   DefaultTimeoutStopSec = "5s";
  # };
  # Ever sleep for TIMEOUT max, then poweroff gracefully
  powerManagement.powerDownCommands = ''
    TIMEOUT=${toString (16 * 3600)}
    TARGET_TIME=$(( $(date +%s) + $TIMEOUT ))
    echo "$TARGET_TIME" > /run/expected_rtc_wake
    echo 0 > /sys/class/rtc/rtc0/wakealarm
    echo "+$TIMEOUT" > /sys/class/rtc/rtc0/wakealarm
  '';
  powerManagement.resumeCommands = with pkgs; ''
    modprobe -r psmouse && modprobe psmouse
    if [ -f /run/expected_rtc_wake ]; then
      NOW=$(date +%s)
      EXPECTED=$(cat /run/expected_rtc_wake)
      rm /run/expected_rtc_wake
      if [ "$NOW" -ge "$EXPECTED" ]; then
        ${systemd}/bin/systemd-run -M ${config.environment.sessionVariables.USER}@ --user ${pkgs.sway}/bin/swaymsg '[app_id=.*]kill'
        ${systemd}/bin/systemd-run --on-active=5s ${systemd}/bin/systemctl poweroff # The only way to poweroff from resumeCommands that works
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
      [
        b612
        jetbrains-mono
        terminus_font
        font-awesome
      ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
    fontconfig = {
      enable = true;
    };
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true; # Enables the Blueman graphical tool

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
        ExecStart = "${pkgs.trash-cli}/bin/trash-empty 7";
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
    trustedInterfaces = [ "p2p-wl+" ]; # for gnome-network-displays
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

  # fix flatpak apps not using xdg-open correctly
  systemd.user.services.xdg-desktop-portal = {
    environment = pkgs.lib.mkForce {
      PATH = "$PATH:/run/current-system/sw/bin:/var/lib/flatpak/exports/bin";
    };
  };

  services.udisks2 = {
    enable = true; # required for udiskie
    # mountOnMedia = true; # otherwise it creates /run/media/$USER without `x` permissions, which doesn't let Transmission download
    settings = {
      "mount_options.conf" = {
        defaults = {
          ntfs_drivers = "ntfs-3g,ntfs3"; # fix mounting error
        };
      };
    };
  };
  # programs.fuse.userAllowOther = true; # NOTE might be needed on exfat external drive for apps

  services.transmission = {
    # NOTE: careful not to enable the daemon, that will make the gui create broken states.
    settings = {
      preallocation = 0; # actually fixes minutes long preallocation
      umask = 2; # 002 umask, files created as 664/775
    };
  };

  services.tlp = {
    enable = true;
    settings = {
      USB_AUTOSUSPEND = 0;
      CPU_SCALING_GOVERNOR_ON_BAT = "performance";
    };
  };

  # TODO remove if after enabling trackpoint it still floats
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="TPPS/2 IBM TrackPoint", RUN+="${pkgs.runtimeShell} -c 'echo 0 > /sys/bus/serio/devices/serio1/drift_time'"
    ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="TPPS/2 IBM TrackPoint", ENV{LIBINPUT_DISABLE_DEVICE}="1"
  '';
  systemd.tmpfiles.rules = [
    "w /sys/bus/serio/devices/serio1/sensitivity -- - - - 0"
    "w /sys/bus/serio/devices/serio1/speed      -- - - - 0"
  ];

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
  system.stateVersion = "26.05"; # Did you read the comment?
}
