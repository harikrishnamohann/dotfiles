{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "i8042.nokbd" ];
  services.logind.settings.Login = {
    HandlePowerKey = "hibernate";
  };

  networking.networkmanager.enable = true;
  networking.hostName = "nixos";
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "all" ];

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
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
  services.xserver.videoDrivers = ["nvidia"];
  ## f*** nvidia things
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:6:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
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

  programs.command-not-found.enable = true;
  programs.fish = {
    enable = true;
    generateCompletions = true;
    shellAbbrs = {
      nd = "nix develop";
    };

  };
  programs.fish.shellAbbrs = { gco = "git checkout"; npu = "nix-prefetch-url"; };

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      user.name = "Harikrishna Mohan";
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

      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -n M-H previous-window
      bind -n M-L next-window
    '';    
  };

  users.users.hk = {
    isNormalUser = true;
    description = "Harikrishna Mohan";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      gnome-text-editor
      loupe # image viewer
      baobab # disk usage analyzer
      papers # document viewer
      snapshot # camera app
      showtime # video player
      decibels # audio player
      resources # like btop
      gnome-calculator
      gnome-calendar
      tree
      fastfetch
      firefox
      tldr
      telegram-desktop
      libreoffice
      gimp
      obsidian
      pureref
      python315
      clang
      lua
      ty # lsp for python
      lldb
      clang-tools
      lua-language-server
      bash-language-server
      pastel
      ffmpeg-full
    ];
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    maple-mono.NF
    adwaita-fonts
    nerd-fonts."m+"
  ];


  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # garbage collection
  nix.gc = {
    automatic = true;    
    dates = "weekly";
    options = "--delete-older-than 10d";
  };
  nix.settings.auto-optimise-store = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443];
    allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
      { from = 8000; to = 8010; }
    ];
  };
  
  ##################
  ## ENVIRONMENTS ##
  ##################

  # @HYPRLAND
  environment.systemPackages = with pkgs; [
    helix
    wl-clipboard
    wlsunset
    playerctl
    brightnessctl
    adwaita-icon-theme
    hyprpolkitagent
    hyprpaper
    gparted
    nixd
    nixdoc
    alacritty
    nautilus
    hyprls
    fuzzel
    pavucontrol
    hyprlock
    swaynotificationcenter
    ashell
    upower
    power-profiles-daemon
    networkmanagerapplet
    cliphist
    blueman
    hyprpicker
    hyprshot
    rose-pine-hyprcursor
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    wl-screenrec
    libnotify
    slurp
    glib
  ];

  services.displayManager.ly.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.hypridle.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        gtk-theme = "Adwaita";
        icon-theme = "Adwaita";
        font-name = "Adwaita Sans Medium 12";
        document-font-name = "Adwaita Sans Medium 12";
        monospace-font-name = "Maple Mono NL Medium 12";
      };
    }
  ];

  services.gvfs.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.GIO_EXTRA_MODULES = [ "${config.services.gvfs.package}/lib/gio/modules" ]; 

  
  # don't change this
  system.stateVersion = "25.05";
}

