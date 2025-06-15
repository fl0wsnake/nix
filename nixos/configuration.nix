# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ 
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
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
  time.timeZone = "Europe/Kyiv";

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

  programs.sway = {
    enable = true;
    # wrapperFeatures.gtk
  };

  services.greetd = {
    enable = true;
    vt = 1;
    settings = {
      default_session = {
        command = "${pkgs.sway}/bin/sway";
        user = "nix";
      };
    };
  };

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
    shell = pkgs.zsh;
  };

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

  programs.bash = {
    shellAliases = {
      nr="sudo nixos-rebuild switch";
      e="nvim";
      se="sudo -e";
    };
    interactiveShellInit = ''
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    tmux attach-session -t base || exec tmux new-session -s base
fi
  '';
  };

  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
        set -g base-index 1
        set -s escape-time 0
        bind-key -n M-Tab select-window -l
        bind-key -n M-1 select-window -t :1
        bind-key -n M-2 select-window -t :2
        bind-key -n M-3 select-window -t :3
        bind-key -n M-4 select-window -t :4
        bind-key -n M-5 select-window -t :5
        bind-key -n M-6 select-window -t :6
        bind-key -n M-7 select-window -t :7
        bind-key -n M-8 select-window -t :8
        bind-key -n M-9 select-window -t :9
        bind-key -n C-S-PageUp swap-window -t -1\; select-window -p
        bind-key -n C-S-PageDown swap-window -t +1\; select-window -n
        bind-key -n M-t new-window
        bind-key -n M-q kill-window
    '';
    };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.variables = {
    GCM_CREDENTIAL_STORE = "plaintext";
    EDITOR = "nvim";
    VISUAL = "nvim";
    EXPLORER = "nnn";
    # Bookmarks
    SYNC="~/Dropbox";
    MY_WIKI="$SYNC/MyWiki";
    MY_TODOS="$SYNC/MyTodos";
    MY_SCREENSHOTS="$SYNC/MyScreenshots";
    # Gnome only supports non-fractional scaling by default. Although "2" is too much for 2560x1440 and "1" is too little.
    GDK_SCALE = "2";
    QT_SCALE_FACTOR = "2";
  };
  environment.sessionVariables = {
    XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.nix.uid}";
    XDG_CURRENT_DESKTOP = "sway"; # Helps applications know they're on Sway
    XDG_SESSION_TYPE = "wayland"; # Explicitly state the session type
  };

  environment.systemPackages = with pkgs; [
    gnumake # for bin/make
    libappindicator # for Dropbox
    neovim vimPlugins.lazy-nvim
    alacritty nnn
    sway wl-clipboard
    xclip # for backup
    git git-credential-manager
    vivaldi dropbox
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
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
  system.stateVersion = "25.05"; # Did you read the comment?
}
