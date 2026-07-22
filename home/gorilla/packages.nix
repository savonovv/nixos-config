{ pkgs, ... }:

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
    lldb
    opencode
    pavucontrol
    playerctl
    rose-pine-hyprcursor
    telegram-desktop
    unzip
    wl-clipboard
    zig
    zls
  ];
}
