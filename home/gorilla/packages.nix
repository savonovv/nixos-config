{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    claude-code
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
