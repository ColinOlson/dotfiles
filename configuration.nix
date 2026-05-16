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
    ./machines/${hostname}/hardware-configuration.nix
    ./modules/programs.nix
    ./modules/services.nix
    ./modules/systemPackages.nix
    ./modules/virtualisaton.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.configurationLimit = 10;
  };

  nixpkgs.config.allowUnfree = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings.General = {
    Enable = "Source,Sink,Media,Socket";
  };

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    hosts = {
      "127.0.0.1" = [
        "sql.cartanium.docker"
        "elastic.cartanium.docker"
      ];
    };

    firewall = {
      allowedTCPPorts = [
        53317
        7783
      ];
      allowedUDPPorts = [
        53317
        7783
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

  security.sudo.extraRules = [
    {
      users = [ "colino" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  users.groups = {
    plugdev = { };
    wireshark = { };
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
      "wireshark"
    ];
  };

  environment.pathsToLink = [
    "/share/applications"
    "/share/mime"
  ];

  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  documentation = {
    enable = true;
    man.enable = true;
    man.cache.enable = true;
  };

  system.stateVersion = "25.11";
}
