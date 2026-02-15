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

    zsh.enable = true;

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
}
