{ inputs, pkgs, lib, ... }: {

  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  programs.zen-browser = {
    enable = true;
    suppressXdgMigrationWarning = true;

    policies = {
      EnableTrackingProtection = {
        Value                 = true;
        Category              = "strict";
        BaselineExceptions    = true;
        ConvenienceExceptions = false;
      };
    };

    profiles.default = {
      id        = 0;
      isDefault = true;
      pinsForce = true;

      search = {
        force = true;
        default = "ddg";
      };

      pins = {
        "github" = {
          id          = "a1b2c3d4-e5f6-7890-abcd-ef1234567890";
          url         = "https://github.com";
          isEssential = true;
          position    = 100;
        };
        "codeberg" = {
          id          = "b2c3d4e5-f6a7-8901-bcde-f12345678901";
          url         = "https://codeberg.org";
          isEssential = true;
          position    = 200;
        };
        "piratenet" = {
          id          = "c3d4e5f6-a7b8-9012-cdef-123456789012";
          url         = "https://www.shu.edu/piratenet.html";
          isEssential = true;
          position    = 300;
        };
      };

      settings = {
        # ── Appearance ────────────────────────────────────────────────
        # Website appearance: dark (0=dark, 1=light, 2=system)
        "layout.css.prefers-color-scheme.content-override" = 0;

        # Default font: Noto Serif
        "font.default.x-western"    = "serif";
        "font.name.serif.x-western" = "Noto Serif";

        # ── Vertical tabs ─────────────────────────────────────────────
        "zen.tabs.show-newtab-vertical" = false;
        "zen.tabs.show-newtab-button-top" = false;

        # ── Search ────────────────────────────────────────────────────
        "browser.search.separatePrivateDefault"            = false;
        "browser.search.separatePrivateDefault.ui.enabled" = false;

        "browser.search.suggest.enabled"    = true;
        "browser.urlbar.suggest.searches"   = true;

        # ── Privacy & Security ──────────────────────
        "browser.contentblocking.category"                          = "strict";
        "privacy.trackingprotection.allow_list.baseline.enabled"    = true;
        "privacy.trackingprotection.allow_list.convenience.enabled" = false;
        "network.prefetch-next"                   = false;

        # ── Passwords ─────────────────────────────────────────────────
        "signon.rememberSignons"                          = false;
        "signon.autofillForms"                            = false;
        "signon.generation.enabled"                       = false;
        "signon.firefoxRelay.feature"                     = "disabled";
        "signon.management.page.breach-alerts.enabled"    = false;

        # Allow Bitwarden to autofill
        "signon.formlessCapture.enabled"          = false;
        "extensions.formautofill.available"       = "off";
        "signon.privatebrowsing.autofill"         = false;

        # ── Payment methods ───────────────────────────────────────────
        "extensions.formautofill.creditCards.enabled"   = false;
        "extensions.formautofill.creditCards.supported" = "off";

        # ── Addresses ─────────────────────────────────────────────────
        "extensions.formautofill.addresses.enabled"   = false;
        "extensions.formautofill.addresses.supported" = "off";
      };

      mods = [
        "a6335949-4465-4b71-926c-4a52d34bc9c0"
        "253a3a74-0cc4-47b7-8b82-996a64f030d5"
        "906c6915-5677-48ff-9bfc-096a02a72379"
        "c01d3e22-1cee-45c1-a25e-53c0f180eea8"
        "0c3d77bf-44fc-47a6-a183-39205dfa5f7e"
        "4596d8f9-f0b7-4aeb-aa92-851222dc1888"
        "ae051a40-3e3a-429a-a6f4-199a28b18a75"
        "c8d9e6e6-e702-4e15-8972-3596e57cf398"
      ];

      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
        darkreader
        decentraleyes
        bitwarden
        duckduckgo-privacy-essentials
        privacy-badger
        cookie-autodelete
      ];
    };
  };

  home.activation.zenMods = lib.hm.dag.entryAfter ["writeBoundary"] ''
    MODS_SRC="$HOME/.config/zen/default/zen-mods-nix-managed.json"
    MODS_DST="$HOME/.config/zen/default/zen-mods.json"
    if [ -f "$MODS_SRC" ]; then
      cp "$MODS_SRC" "$MODS_DST"
    fi
  '';
}
