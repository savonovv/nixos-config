{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      lua-language-server
      nixd
      nixfmt

      rust-analyzer
      gopls
      pyright
      zls

      clang-tools
      gdb
      cmake
      gnumake
      ninja
      tree-sitter

      ripgrep
      fd
      gcc
      git
    ];
    initLua = builtins.readFile ./init.lua;
    };

}
