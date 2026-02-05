{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  homebrew.casks = [
    "firefox"
    "google-drive"
  ];

  homebrew.brews = [
    "mas"
  ];

  homebrew.masApps = {

  };
}
