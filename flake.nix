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
      self,
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
          overlays = [ self.overlays.default ];
        };

      mkNixosHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit hostname;
          };
          modules = [
            (_: {
              nixpkgs.overlays = [ self.overlays.default ];
            })
            ./configuration.nix
          ];
        };
      mkHome =
        {
          system,
          packs,
          home,
          username,
          extraArgs ? { },
        }:
        home.lib.homeManagerConfiguration {
          pkgs = mkPkgs system packs;
          modules = [ ./home.nix ];
          extraSpecialArgs = extraArgs;
        };
    in
    {
      overlays.default = final: prev: {
        # crosspaste = final.callPackage ./pkgs/crosspaste-appimage { };
      };

      nixosConfigurations."nixos-lappy" = mkNixosHost "nixos-lappy";
      nixosConfigurations."nixos-desktop" = mkNixosHost "nixos-desktop";

      homeConfigurations.colino = mkHome {
        system = "x86_64-linux";
        packs = nixpkgs;
        home = home-manager;
        username = "colino";
        extraArgs = {
          inherit noctalia;
        };
      };
    };
}
