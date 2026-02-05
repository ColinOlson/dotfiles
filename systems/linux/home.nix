{
  config,
  pkgs,
  noctalia ? null,
}:
{
  imports = [ noctalia.homeModules.default ];

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 600;
        command = "/home/colino/.nix-profile/bin/noctalia-shell ipc call lockScreen lock";
      }
      {
        timeout = 630;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
      }
    ];
    events.after-resume = "${pkgs.niri}/bin/niri msg action power-on-monitors";
  };

  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
  };

  programs = {
    noctalia-shell = {
      enable = true;
    };
  };

  xdg = {
    configFile = {
      project-launcher.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Dotfiles/config/project-launcher";
      "niri/config.kdl".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Dotfiles/config/niri/config.kdl";
    };
  };
}
