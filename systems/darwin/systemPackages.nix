{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  homebrew.casks = [
    "firefox"
    "google-drive"
    "orbstack"
  ];

  homebrew.brews = [
    "mas"
  ];

  homebrew.masApps = {

  };
}
