# vim: set ts=2 sw=2: #

{
  config,
  pkgs,
  hostname,
  ...
}:

let
  myPython = pkgs.python3.withPackages (
    ps: with ps; [
      pydbus
      pygobject3
    ]
  );
  myYarn = pkgs.nodejs_20.pkgs.yarn.override {
    nodejs = pkgs.nodejs_20;
  };
in
{
  imports = [
    ./machines/${hostname}/hardware-configuration.nix
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib # libstdc++.so.6
      zlib
      openssl
      libffi
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  virtualisation.docker = {
    enable = true;
  };

  hardware.bluetooth.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  networking.hosts = {
    "127.0.0.1" = [
      "sql.cartanium.docker"
      "elastic.cartanium.docker"
    ];
  };

  time.timeZone = "America/Vancouver";

  i18n.defaultLocale = "en_CA.UTF-8";

  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # /etc/nixos/configuration.nix
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = { };

  programs.niri.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;

    package = pkgs.sunshine.override {
      cudaSupport = true;
      inherit (pkgs) cudaPackages;
    };
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.zsh.enable = true;

  users.groups = {
    plugdev = { };
  };

  users.users.colino = {
    isNormalUser = true;
    description = "Colin Olson";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "input"
      "plugdev"
    ];
  };

  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = false; # recommended for better scheduling/latency
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-7.0.410"
  ];

  environment.systemPackages = with pkgs; [
    alacritty
    brave
    btop
    cifs-utils
    clang
    curl
    davinci-resolve
    dbus
    direnv
    discord
    docker
    dotnet-sdk_7
    duf
    dust
    eza
    fastfetch
    fd
    feh
    filezilla
    fuzzel
    fzf
    gcc
    glib
    gnumake
    htop
    jetbrains.datagrip
    jetbrains.pycharm
    jetbrains.rider
    jetbrains.rust-rover
    jetbrains.webstorm
    jq
    keepass
    kitty
    lazydocker
    lazygit
    libreoffice
    lua-language-server
    lutris
    myPython
    myYarn
    neovim
    nerd-fonts.meslo-lg
    nirius
    nixfmt
    nodejs_20
    oxker
    pkg-config
    playerctl
    postman
    quickshell
    qutebrowser
    rclone
    remmina
    ripgrep
    rustdesk
    rustup
    sshs
    swayidle
    thunderbird
    tmuxp
    tree-sitter
    ungoogled-chromium
    unzip
    vlc
    vulkan-tools
    wget
    wofi
    xwayland-satellite
  ];

  programs.steam = {
    enable = true;
  };

  hardware.graphics = {
    enable = true;
  };

  services.openssh.enable = true;

  services.udev.extraRules = ''
    # Rules for Oryx web flashing and live training
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

    # Legacy rules for live training over webusb (Not needed for firmware v21+)
      # Rule for all ZSA keyboards
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
      # Rule for the Moonlander
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
      # Rule for the Ergodox EZ
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
      # Rule for the Planck EZ
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

    # Wally Flashing rules for the Ergodox EZ
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

    # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
    # Keymapp Flashing rules for the Voyager
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
  '';

  system.stateVersion = "25.11";
}
