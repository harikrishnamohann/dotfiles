{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "i8042.nokbd" ];

  networking.networkmanager.enable = true;
  networking.hostName = "nixos";
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "all" ];

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  ## f*** nvidia things
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
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
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.libinput.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
  };

    hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
        ControllerMode = "bredr";
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  programs.command-not-found.enable = true;
  programs.fish = {
    enable = true;
    generateCompletions = true;
  };

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      user.name = "Harikrishna Mohan";
      user.email = "harikrishnamohan@proton.me";
    };
  };

  programs.kdeconnect.enable = true;
  users.users.hk = {
    isNormalUser = true;
    description = "Harikrishna Mohan";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      tree
      fastfetch
      firefox
      tldr
      helix
      bat
      gnome-text-editor
      vlc
      telegram-desktop
      libreoffice
      vscode
      gimp
      loupe # image viewer
      baobab # disk usage analyzer
      papers # document viewer
      snapshot # camera app
      resources # like btop
      obsidian
      pureref
      gnome-calculator
      gnome-calendar
      python315
      ty
      clang
      clang-tools
      lldb
      lua
      lua-language-server
      bash-language-server
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
  services.xserver.enable = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # garbage collection
  nix.gc = {
    automatic = true;    
    dates = "weekly";
    options = "--delete-older-than 10d";
  };
  nix.settings.auto-optimise-store = true;

  
  ##################
  ## ENVIRONMENTS ##
  ##################

  # @HYPRLAND
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wlsunset
    playerctl
    brightnessctl
    adwaita-icon-theme
    hyprpolkitagent
    hyprpaper
    nixd
    nixdoc
    alacritty
    nautilus
    hyprls
    fuzzel
    hyprlock
    mako
    ashell
    upower
    power-profiles-daemon
    networkmanagerapplet
    cliphist
    blueman
    hyprshot
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

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.GIO_EXTRA_MODULES = [ "${config.services.gvfs.package}/lib/gio/modules" ]; 
  services.gvfs.enable = true;


  
  # don't change this
  system.stateVersion = "25.05";
}

