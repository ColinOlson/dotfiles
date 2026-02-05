# vim: set ts=2 sw=2: #

{
  description = "Colin's Nixos config";

  inputs = {
    # Linux / NixOS
    nixpkgs-linux.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager-linux.url = "github:nix-community/home-manager/master";
    home-manager-linux.inputs.nixpkgs.follows = "nixpkgs-linux";

    noctalia-linux = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-linux";
    };

    # macOS / nix-darwin
    nixpkgs-darwin.url = "github:nixos/nixpkgs?ref=nixpkgs-25.11-darwin";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    home-manager-darwin.url = "github:nix-community/home-manager/release-25.11";
    home-manager-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

  };

  outputs =
    {
      nixpkgs-linux,
      home-manager-linux,
      noctalia-linux,

      nixpkgs-darwin,
      nix-darwin,
      home-manager-darwin,
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
        nixpkgs-linux.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit hostname;
          };
          modules = [ ./systems/linux/configuration.nix ];
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
            ./systems/darwin/configuration.nix
            home-manager-darwin.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = {
                  imports = [ ./modules/home-common.nix ];
                  home.homeDirectory = nixpkgs-darwin.lib.mkForce /Users/colino;
                };
              };
            }
          ];
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
          modules = [ ./modules/home-common.nix ] ++ extraModules;
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
        packs = nixpkgs-linux;
        home = home-manager-linux;
        username = "colino";
        extraModules = [ ./systems/linux/home.nix ];
        extraArgs = {
          noctalia = noctalia-linux;
        };
      };

      homeConfigurations.colino-darwin = mkHome {
        system = "aarch64-darwin";
        packs = nixpkgs-darwin;
        home = home-manager-darwin;
        username = "colino";
        extraModules = [ ./systems/darwin/home.nix ];
        extraArgs = { };
      };
    };
}
