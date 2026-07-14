{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      manager = {
        show_hidden = true;
        sort_by = "natural";
        sort_dir_first = true;
        linemode = "size";
      };

      preview = {
        wrap = "no";
        tab_size = 2;
      };

      opener = {
        edit = [
          {
            run = ''nvim "$@"'';
            block = true;
            for = "unix";
          }
        ];

        open = [
          {
            run = ''xdg-open "$1"'';
            orphan = true;
            desc = "Open";
            for = "unix";
          }
        ];
      };
    };
  };
}
