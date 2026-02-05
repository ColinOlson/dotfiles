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
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-7.0.410"
  ];

  environment.systemPackages = with pkgs; [
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
}
