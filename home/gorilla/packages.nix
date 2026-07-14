{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    chromium
    eza
    gh
    opencode
    pavucontrol
    playerctl
    rose-pine-hyprcursor
    telegram-desktop
    unzip
    wl-clipboard
  ];
}
