{
  description = "Darkawower nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      darwinConfigurations."Arturs-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          (
            { pkgs, ... }:
            import ./darwin.nix {
              inherit self;
              inherit pkgs;
            }
          )
        ];
      };

      homeConfigurations.darkawower = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "aarch64-darwin"; };
        modules = [ ./home.nix ];
      };
    };
}
