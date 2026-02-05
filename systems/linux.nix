# vim: set ts=2 sw=2: #

{
  pkgs,
  hostname,
  ...
}:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  imports = [
    ../machines/${hostname}/hardware-configuration.nix
    ../modules/linuxServices.nix
    ../modules/systemPackages.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # Use latest kernel.
    kernelPackages = pkgs.linuxPackages_latest;
  };

  hardware.bluetooth.enable = true;

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    hosts = {
      "127.0.0.1" = [
        "sql.cartanium.docker"
        "elastic.cartanium.docker"
      ];
    };
  };

  time.timeZone = "America/Vancouver";

  i18n.defaultLocale = "en_CA.UTF-8";

  security = {
    polkit.enable = true;
    pam.services.swaylock = { };
    rtkit.enable = true;
  };

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

  environment.pathsToLink = [
    "/share/applications"
    "/share/mime"
  ];

  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  system.stateVersion = "25.11";
}
