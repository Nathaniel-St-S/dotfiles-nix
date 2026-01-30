{ inputs, nixpkgs, nur, home-manager }:

{ hostname, isLaptop ? true, username ? "nathaniels" }:

nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs isLaptop username;
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
        extraSpecialArgs = { inherit inputs username; };
        backupFileExtension = "hm-backup";
        users.${username} = import ../modules/home;
      };
    }
  ];
}
