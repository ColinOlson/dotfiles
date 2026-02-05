# vim: set ts=2 sw=2: #

{
  description = "Colin's Nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-darwin,
      noctalia,
      ...
    }:
    let
      mkPkgs =
        system:
        import nixpkgs {
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
          modules = [ ./systems/linux.nix ];
        };
      mkDarwinHost =
        {
          hostname,
          username,
        }:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit hostname; };
          modules = [
            ./systems/darwin.nix

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import ./home.nix;
              };
            }
          ];
        };
      mkHome =
        {
          system,
          username,
          extraArgs ? { },
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          modules = [ ./home.nix ];
          extraSpecialArgs = extraArgs;
        };
    in
    {
      nixosConfigurations."nixos-lappy" = mkNixosHost "nixos-lappy";
      nixosConfigurations."nixos-desktop" = mkNixosHost "nixos-desktop";

      darwinConfigurations."macos-lappy-pro" = mkDarwinHost {
        hostname = "macos-lappy-pro";
        username = "colino";
      };

      homeConfigurations.colino-linux = mkHome {
        system = "x86_64-linux";
        username = "colino";
        extraArgs = { inherit noctalia; };
      };

      homeConfigurations.colino-darwin = mkHome {
        system = "aarch64-darwin";
        username = "colino";
        extraArgs = { };
      };
    };
}
