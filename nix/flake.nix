{
  description = "Nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    darwin-login-items.url = "github:uncenter/nix-darwin-login-items";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      darwin-login-items,
      ...
    }:
    let
      user = import ./user.nix;
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      darwinConfigurations.${user.hostname} = nix-darwin.lib.darwinSystem {
        modules = [
          darwin-login-items.darwinModules.default
          (
            { pkgs, ... }:
            import ./darwin.nix {
              inherit self pkgs user;
            }
          )
        ];
      };

      homeConfigurations.${user.username} = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };
        modules = [
          ./home.nix
          { _module.args = { inherit user; }; }
        ];
      };
    };
}
