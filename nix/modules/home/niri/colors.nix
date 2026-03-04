{ pkgs, config, lib, ... }:
let
  fallback-active = "#3F4145";
  fallback-urgent = "#fd6b6b";

  cacheDir      = "${config.home.homeDirectory}/.cache/niri";
  storeConfig   = "${cacheDir}/store-config.kdl";
  configCopy    = "${config.home.homeDirectory}/.config/niri/config.kdl";

  niri-generate-colors = pkgs.writeShellScriptBin "niri-generate-colors" ''
    set -eo pipefail
    [ -f "$HOME/.cache/wal/colors.sh" ] || exit 0
    set +u
    source "$HOME/.cache/wal/colors.sh"
    set -u

    sed \
      -e "s/${fallback-active}/$color4/g" \
      -e "s/${fallback-urgent}/$color5/g" \
      "${storeConfig}" > "${configCopy}"
  '';
in
{
  home.packages = [ niri-generate-colors ];

  programs.niri.settings = {
    layout.border.active     = { color = fallback-active; };
    layout.focus-ring.active = { color = fallback-active; };
  };

  home.activation.cleanNiriSymlink = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    rm -f "${configCopy}" "${configCopy}.hm-backup"
  '';

  home.activation.applyNiriColors = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    mkdir -p "${cacheDir}"
    _store=$(${pkgs.coreutils}/bin/readlink -f "${configCopy}" 2>/dev/null || true)
    if [[ "$_store" == /nix/store/* ]]; then
      ${pkgs.coreutils}/bin/cp "$_store" "${storeConfig}"
      ${pkgs.coreutils}/bin/chmod 644 "${storeConfig}"
      rm -f "${configCopy}"
      ${pkgs.coreutils}/bin/cp "${storeConfig}" "${configCopy}"
      ${pkgs.coreutils}/bin/chmod 644 "${configCopy}"
    fi
  '';
}
