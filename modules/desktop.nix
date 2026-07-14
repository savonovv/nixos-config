{ config, pkgs, ... }:

let
  sddmTheme = pkgs.runCommand "sddm-minimal-lock-theme" { } ''
    theme="$out/share/sddm/themes/minimal-lock"
    mkdir -p "$theme"
    cp ${./sddm-theme/Main.qml} "$theme/Main.qml"
    cp ${./sddm-theme/metadata.desktop} "$theme/metadata.desktop"
    cp ${../assets/wallpaper.png} "$theme/wallpaper.png"
  '';
in
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.uwsm.enable = true;

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "${sddmTheme}/share/sddm/themes/minimal-lock";
    };
  };

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    HandlePowerKeyLongPress = "ignore";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];

    config.common.default = [
      "hyprland"
      "gtk"
    ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  programs.dconf.enable = true;
}
