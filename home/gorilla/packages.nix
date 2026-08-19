{ inputs, pkgs, ... }:

let
  lmms = pkgs.symlinkJoin {
    name = "lmms-full-scaled";
    paths = [ pkgs.lmms-full ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/lmms" \
        --set QT_QPA_PLATFORM xcb \
        --set QT_SCALE_FACTOR 1.5
    '';
  };
in
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
    lmms
    nodejs
    odin
    ols
    inputs.opencode.packages.${pkgs.system}.opencode
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
