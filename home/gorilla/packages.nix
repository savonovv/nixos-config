{ inputs, pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    claude-code
    chromium
    eza
    exercism
    freecad
    gcc
    gdb
    gh
    opencode
    pavucontrol
    playerctl
    rose-pine-hyprcursor
    telegram-desktop
    unzip
    wl-clipboard
    inputs.zig-overlay.packages.${pkgs.stdenv.hostPlatform.system}.master
    inputs.zls.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
