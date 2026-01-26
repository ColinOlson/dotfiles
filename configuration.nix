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
      cudaPackages = pkgs.cudaPackages;
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

  users.users.colino = {
    isNormalUser = true;
    description = "Colin Olson";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    brave
    btop
    clang
    curl
    davinci-resolve
    dbus
    direnv
    discord
    docker
    dotnet-sdk_10
    duf
    dust
    eza
    fastfetch
    fd
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
    keepass
    kitty
    lazydocker
    lazygit
    libreoffice
    lua-language-server
    lutris
    neovim
    nerd-fonts.meslo-lg
    nixfmt
    nodejs
    oxker
    pkg-config
    postman
    myPython
    qutebrowser
    rclone
    ripgrep
    rustdesk
    rustup
    tree-sitter
    ungoogled-chromium
    unzip
    vlc
    wget
  ];

  programs.steam = {
    enable = true;
  };

  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.openssh.enable = true;

  system.stateVersion = "25.11";
}
