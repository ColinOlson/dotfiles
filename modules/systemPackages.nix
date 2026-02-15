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
    bat
    bitwarden-desktop
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
    keepassxc
    kitty
    lazydocker
    lazygit
    libreoffice
    lua-language-server
    lutris
    meld
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
    sshfs
    sshs
    swayidle
    telegram-desktop
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
}
