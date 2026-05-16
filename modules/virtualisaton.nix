{ pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;

  programs.virt-manager.enable = true;

  users.users.colino.extraGroups = [
    "libvirtd"
    "kvm"
    "video"
  ];

  virtualisation.spiceUSBRedirection.enable = true;
}
