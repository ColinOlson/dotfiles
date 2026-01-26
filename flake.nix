# vim: set ts=2 sw=2: #
#
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations."nixos-lappy" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { hostname = "nixos-lappy"; };
        modules = [ ./configuration.nix ];
      };

      nixosConfigurations."nixos-desktop" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { hostname = "nixos-desktop"; };
        modules = [ ./configuration.nix ];
      };

      homeConfigurations.colino = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home.nix
        ];

        extraSpecialArgs = {
          inherit noctalia;
        };
      };
    };
}
