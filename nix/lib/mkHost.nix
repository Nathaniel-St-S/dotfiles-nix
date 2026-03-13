{ inputs, nixpkgs, home-manager }:

{ hostname, isLaptop ? true, username ? "nathaniels" }:

let
  autoImport = import ./autoImport.nix { inherit (nixpkgs) lib; };
in
nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs isLaptop username autoImport;
  };

  modules = [
    inputs.impermanence.nixosModules.impermanence
    inputs.agenix.nixosModules.default

    ../hosts/${hostname}
    ../modules/system/common.nix
    ../modules/system/impermanence.nix
    (if isLaptop
      then ../modules/system/laptop.nix
      else ../modules/system/desktop.nix)

    { age.secrets."${hostname}-password".file =
        "${inputs.secrets}/age/${hostname}.age"; }

    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs    = true;
        useUserPackages  = true;
        extraSpecialArgs = { inherit inputs username autoImport; };
        backupFileExtension = "hm-backup";
        sharedModules = [ 
          inputs.niri.homeModules.niri 
          inputs.nix-index-database.homeModules.nix-index
          inputs.spicetify-nix.homeManagerModules.spicetify
        ];
        users.${username} = import ../modules/home;
      };
    }
  ];
}
