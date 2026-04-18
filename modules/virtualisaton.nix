{ pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;

  programs.virt-manager.enable = true;

  users.users.colino.extraGroups = [
    "libvirtd"
    "kvm"
  ];

  virtualisation.spiceUSBRedirection.enable = true;
}
