{ pkgs, ... }:

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
    ../../modules/systemPackagesCommon.nix
    ./systemPackages.nix
  ];

  # Required by nix-darwin — pick once, don’t change casually
  system.stateVersion = 5;
  system.primaryUser = "colino";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  homebrew = {
    enable = true;
    taps = [ "homebrew/cask" ];
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
  };

  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg
  ];

  # Optional but nice defaults — completely safe
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
    };

    dock = {
      autohide = false;
      show-recents = true;
    };

    trackpad = {
      Clicking = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
    };
  };
}
