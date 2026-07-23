{ pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./audio.nix
    ./desktop.nix
    ./fastfetch.nix
    ./firefox.nix
    ./fish.nix
    ./ghostty.nix
    ./opencode.nix
    ./tmux.nix
    ./yazi.nix
    ./hypr
    ./nvim
  ];

  home = {
    username = "gorilla";
    homeDirectory = "/home/gorilla";
    stateVersion = "26.05";
  };

  home.pointerCursor = {
    package = pkgs.rose-pine-cursor;
    name = "BreezeX-RosePine-Linux";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.home-manager.enable = true;

  xdg.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  systemd.user.startServices = "sd-switch";
}
