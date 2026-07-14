{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;

      window-padding-x = 8;
      window-padding-y = 0;

      background = "1f1f28";
      foreground = "dcd7ba";

      cursor-color = "c8c093";
      cursor-text = "1f1f28";

      selection-background = "2d4f67";
      selection-foreground = "c8c093";

      palette = [
        "0=#16161d"
        "1=#c34043"
        "2=#76946a"
        "3=#c0a36e"
        "4=#7e9cd8"
        "5=#957fb8"
        "6=#6a9589"
        "7=#c8c093"
        "8=#727169"
        "9=#e82424"
        "10=#98bb6c"
        "11=#e6c384"
        "12=#7fb4ca"
        "13=#938aa9"
        "14=#7aa89f"
        "15=#dcd7ba"
      ];

      shell-integration = "fish";
      shell-integration-features = "cursor,sudo,title";

      confirm-close-surface = false;
      copy-on-select = "clipboard";

      gtk-single-instance = true;
      gtk-titlebar = false;
      background-opacity = 0.85;
      background-opacity-cells = true;
      background-blur = true;

      window-padding-color = "background";
      window-decoration = "none";

      cursor-style = "block";
      cursor-style-blink = false;

      keybind = [
        "ctrl+insert=copy_to_clipboard"
        "shift+insert=paste_from_clipboard"
        "ctrl+shift+f10=reload_config"
      ];
    };
  };
}
