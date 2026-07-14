{ inputs, lib, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  firefoxAddons = inputs.firefox-addons.packages.${system};
  buildFirefoxAddon = inputs.firefox-addons.lib.${system}.buildFirefoxXpiAddon;

  kanagawaWave = buildFirefoxAddon {
    pname = "kanagawa-wave-dark-theme";
    version = "2.5";
    addonId = "{7efc2a80-496f-49b1-88db-4ddd7d312757}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4847676/kanagawa_wave_dark_theme-2.5.xpi";
    sha256 = "57da9fe43e2c37a5e9eeaaf350128e94c373869e04a345acb85dc91372824953";
    meta = {
      description = "Kanagawa Wave dark theme for Firefox";
      license = lib.licenses.cc-by-40;
      mozPermissions = [ ];
      platforms = lib.platforms.all;
    };
  };
in
{
  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      isDefault = true;
      path = "w8mhm5bw.default";

      extensions.packages = [
        firefoxAddons.tridactyl
        firefoxAddons.ublock-origin
        kanagawaWave
      ];

      settings = {
        "browser.contentblocking.category" = "standard";
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSearch" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.startup.page" = 3;
        "browser.tabs.inTitlebar" = 1;
        "browser.translations.neverTranslateLanguages" = "ru";
        "extensions.activeThemeID" = "{7efc2a80-496f-49b1-88db-4ddd7d312757}";
        "extensions.autoDisableScopes" = 0;
        "layout.css.always_underline_links" = true;
        "layout.css.prefers-color-scheme.content-override" = 0;
        "media.eme.enabled" = true;
        "privacy.clearOnShutdown_v2.formdata" = true;
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.visibility" = "expand-on-hover";
      };
    };
  };
}
