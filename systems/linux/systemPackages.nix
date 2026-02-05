{ pkgs, ... }:

{
  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib # libstdc++.so.6
        zlib
        openssl
        libffi
      ];
    };

    niri.enable = true;

    firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
      };
    };

    gamescope = {
      enable = true;
      capSysNice = false; # recommended for better scheduling/latency
    };

    steam = {
      enable = true;
    };
  };

  virtualisation.docker = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    cifs-utils
    davinci-resolve
    dbus
    docker
    feh
    filezilla
    fuzzel
    libreoffice
    lutris
    nirius
    playerctl
    quickshell
    rclone
    remmina
    rustdesk
    swayidle
    thunderbird
    ungoogled-chromium
    vlc
    vulkan-tools
    wofi
    xwayland-satellite
  ];
}
