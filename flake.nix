# vim: set ts=2 sw=2: #

{
  description = "Colin's Nixos config";

  inputs = {
    # Linux / NixOS
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      noctalia,
      ...
    }:
    let
      mkPkgs =
        system: packs:
        import packs {
          inherit system;
          config.allowUnfree = true;
        };

      mkNixosHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit hostname;
          };
          modules = [ ./systems/linux/configuration.nix ];
        };
      mkHome =
        {
          system,
          packs,
          home,
          username,
          extraModules ? [ ],
          extraArgs ? { },
        }:
        home.lib.homeManagerConfiguration {
          pkgs = mkPkgs system packs;
          modules = [ ./modules/homeCommon.nix ] ++ extraModules;
          extraSpecialArgs = extraArgs;
        };
    in
    {
      nixosConfigurations."nixos-lappy" = mkNixosHost "nixos-lappy";
      nixosConfigurations."nixos-desktop" = mkNixosHost "nixos-desktop";

      homeConfigurations.colino = mkHome {
        system = "x86_64-linux";
        packs = nixpkgs;
        home = home-manager;
        username = "colino";
        extraModules = [ ./systems/linux/home.nix ];
        extraArgs = {
          inherit noctalia;
        };
      };
    };
}
