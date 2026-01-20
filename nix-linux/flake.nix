{
  description = "My Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser.url = "github:youwen5/zen-browser-flake";
    dms.url = "github:AvengeMedia/DankMaterialShell";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: {
    homeConfigurations."darkawower" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      extraSpecialArgs = { inherit inputs; };
      modules = [ ./home.nix ];
    };

  };
}
