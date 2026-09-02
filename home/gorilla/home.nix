{ isLaptop, lib, pkgs, username, ... }:

{
  imports = [
    ./packages.nix
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
  ] ++ lib.optionals isLaptop [ ./audio.nix ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
    sessionPath = [ "$HOME/.local/bin" ];
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
