{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # disabling laptop keyboard and touchpad
  boot.blacklistedKernelModules = [ 
    "atkbd"
    "i2c_hid_acpi" 
    "i2c_hid" 
    "hid_multitouch" 
    "redmi-wmi"
  ];
  boot.kernelParams = [ 
    "mem_sleep_default=deep" 
    "i8042.reset=1" 
    "i8042.nosmart=1" 
  ];
  services.udev.extraRules = ''
    # Ignore the broken ELAN Touchpad/Mouse interface
    SUBSYSTEM=="input", ATTRS{id}=="i2c:04f3:3122", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    
    # Optional fail-safe: Ensure the internal keyboard matrix can't circumvent sleep
    SUBSYSTEM=="input", ATTRS{name}=="AT Translated Set 2 keyboard", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  services.logind.settings.Login = {
    HandlePowerKey = "hibernate";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitch = "suspend";
  };
  # systemd.sleep.settings.Sleep = { HibernateDelaySec = "1h"; };

  networking.networkmanager.enable = true;
  networking.hostName = "nixos";
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  # i18n.supportedLocales = [ "all" ];

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };

  ## f*** nvidia things
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:6:0:0";
      offload.enable = true;
      offload.enableOffloadCmd = true;
    };
  };

  services.printing.enable = true;
  services.libinput.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
        ControllerMode = "bredr";
      };
      Policy = {
        AutoEnable = false;
      };
    };
  };

  programs.fish = {
    enable = true;
    generateCompletions = true;
    shellAbbrs = {
      ta = "tmux a";
    };
  };

  programs.command-not-found.enable = false;

  programs.git = {
    enable = true;
    config = {
      core.editor = "hx";
      merge.tool = "helix";
      mergetool.helix.cmd = "hx \"$MERGED\"";
      init.defaultBranch = "main";
      user.name = "0x11a41";
      user.email = "harikrishnamohan@proton.me";
    };
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      set -g mode-keys vi
      set-window-option -g mode-keys vi
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -g status-style bg=default
      set-option -g status-position top
      set -g mouse on
      set -g base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      set -g escape-time 5

      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -n M-H previous-window
      bind -n M-L next-window
    '';    
  };

  virtualisation.virtualbox.host.enable = true;

  users.users.hk = {
    isNormalUser = true;
    initialPassword = "nixos";
    description = "Harikrishna Mohan";
    extraGroups = [ "networkmanager" "wheel" "vboxusers" "dialout" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      gnome-text-editor
      loupe # image viewer
      baobab # disk usage analyzer
      papers # document viewer
      gnome-calculator
      telegram-desktop
      gimp
      obsidian
      resources
      rnote
      pixelorama
      krita
      kdePackages.kdenlive
      arduino-ide
      libreoffice
      pureref
      zen-browser
      google-chrome
      vlc
      showtime # video player
      nautilus
      nautilus-open-any-terminal
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  documentation.dev.enable = true;
  documentation.man.cache.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    maple-mono.NF
    adwaita-fonts
    nerd-fonts."m+"
    corefonts
    font-awesome
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # garbage collection
  nix.gc = {
    automatic = true;    
    dates = "monthly";
    options = "--delete-older-than 20d";
  };
  nix.settings.auto-optimise-store = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };

  services.searx = {
    enable = true;
    redisCreateLocally = true;
    settings.server = {
      bind_address = "127.0.0.1";
      port = 8888;
      secret_key = "itissecret";
    };
  };

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--operator=hk" ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false; 
      PermitRootLogin = "no";
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
      { from = 8000; to = 8010; }
    ];
  };

  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    mediaLocation = "/immich";
  };

  environment.systemPackages = with pkgs; [
    (makeDesktopItem {
      name = "photos";
      desktopName = "Photos";
      genericName = "Photo Backup";
      comment = "Self-hosted photo and video backup solution";
      exec = "${pkgs.xdg-utils}/bin/xdg-open http://nixos:2283";
      icon = "zen";
      categories = [ "Network" "WebBrowser" ];
    })
    helix
    wl-clipboard
    playerctl
    brightnessctl
    adwaita-icon-theme
    pastel
    nixd
    nixdoc
    fuzzel
    ashell
    upower
    fastfetch
    power-profiles-daemon
    networkmanagerapplet
    cliphist
    blueman
    wf-recorder
    libnotify
    libinput
    slurp
    glib
    zlib
    gzip
    nmap
    tcpdump
    unzip
    awww
    kitty
    zoxide
    fzf
    tree
    btop
    tldr
    ffmpeg-full
    man-pages
    man-pages-posix
    direnv
    net-tools
    yazi
    presenterm
    vscode-css-languageserver
    superhtml
    vscode-json-languageserver
    typescript
    typescript-language-server
    python313
    ty
    ruff
    lua
    lua-language-server
    clang
    gcc
    gdb
    clang-tools
    lldb
    pkg-config
    wget
    jq
    file
    bash-language-server
    fish-lsp
    libwacom
    hyprls
    hyprsunset
    hyprpolkitagent
    hyprlock
    hyprshot
    swayidle
    rose-pine-hyprcursor
    hyprpicker
    pavucontrol
    gsettings-desktop-schemas
    xdg-desktop-portal-hyprland
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # display manager
  services.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "hyprland-uwsm";

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.gnome.tinysparql.enable = true;
  services.gnome.localsearch.enable = true;
 
  security.pam.services.hyprlock = {};

  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = "Adwaita";
          icon-theme = "Adwaita";
          font-name = "Adwaita Sans Regular 12";
          document-font-name = "Adwaita Sans Regular 12";
          monospace-font-name = "Maple Mono NL Medium 12";
        };
      };
    }
  ];

  services.gvfs.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [ "gtk" ];
    };
  };

  environment.sessionVariables = { 
    LIBVA_DRIVER_NAME = "iHD"; # Forces VA-API video decoding on the Intel card
    NIXOS_OZONE_WL = "1";
    GIO_EXTRA_MODULES = [ "${config.services.gvfs.package}/lib/gio/modules" ];
    EDITOR = "hx";
    VISUAL = "hx";
  };

  # don't change this
  system.stateVersion = "25.05";
}

