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
  # Required by nix-darwin — pick once, don’t change casually
  system.stateVersion = 5;
  system.primaryUser = "colino";

  # Use zsh managed by nix-darwin
  programs.zsh.enable = true;

  # Make Nix tools & a few essentials available system-wide

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-7.0.410"
  ];

  environment.systemPackages = with pkgs; [
    home-manager
    alacritty
    brave
    btop
    clang
    curl
    direnv
    discord
    dotnet-sdk_7
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
    jq
    keepassxc
    kitty
    lazydocker
    lazygit
    lua-language-server
    myPython
    myYarn
    neovim
    nerd-fonts.meslo-lg
    nixfmt
    nodejs_20
    oxker
    pkg-config
    postman
    qutebrowser
    ripgrep
    rustup
    sshs
    telegram-desktop
    tmuxp
    tree-sitter
    unzip
    wget
  ];

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
