{ lib }:

{ path, exclude ? [] }:

let
  allPaths   = if builtins.isList path then path else [ path ];
  excluded   = map toString exclude;
  toPath     = base: name: base + "/${name}";
  importable = base: name: type:
    name != "default.nix" &&
    !(builtins.elem (toString (toPath base name)) excluded) &&
    (type == "directory" || (type == "regular" && lib.hasSuffix ".nix" name));
  importsFor = base:
    map (toPath base) (builtins.attrNames (lib.filterAttrs (importable base) (builtins.readDir base)));
in
  builtins.concatMap importsFor allPaths
