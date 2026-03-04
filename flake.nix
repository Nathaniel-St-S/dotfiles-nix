{
  description = "Nixos dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    impermanence.url = "github:nix-community/impermanence";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@codeberg.org/Nathaniel-St-S/secrets?ref=master";
      flake = false;
    };

    backgrounds = {
      url = "git+ssh://git@github.com/Nathaniel-St-S/backgrounds?ref=master";
      flake = false;
    };
  };

  outputs = { 
    nixpkgs, nur, home-manager,
    zen-browser, firefox-addons, 
    impermanence, agenix, secrets, 
    backgrounds, ... } @ inputs:
    let
      mkHost = import ./nix/lib/mkHost.nix { inherit inputs nixpkgs nur home-manager; };
    in
    {
      nixosConfigurations = {
        kinixys = mkHost {
          hostname = "kinixys";
          isLaptop = true;
        };

        sinixt = mkHost {
          hostname = "sinixt";
          isLaptop = false;
        };
      };
    };
}
