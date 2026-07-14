{ pkgs, ... }:

let
  osAge = pkgs.writeShellApplication {
    name = "os-age";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      birth_epoch=$(stat -c %W /)
      now_epoch=$(date +%s)

      if [ "$birth_epoch" -le 0 ]; then
        birth_epoch=$(stat -c %Y /)
      fi

      age_seconds=$((now_epoch - birth_epoch))
      days=$((age_seconds / 86400))
      hours=$(((age_seconds % 86400) / 3600))
      birth_date=$(date -d "@$birth_epoch" +%F)

      printf '%dd %dh (since %s)\n' "$days" "$hours" "$birth_date"
    '';
  };
in
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "data";
        position = "right";
        padding = {
          left = 3;
          top = 5;
        };
        source = "　ご｀ヽ､\n　ら,り⌒＼\n　　/　 ﾉ 　ﾞヽ\n　　{　/`Y´ ＿）\n　　ヽ'^) ＞. )";
      };

      display = {
        separator = "  ";
        key.width = 8;
      };

      modules = [
        "title"
        "separator"
        {
          type = "os";
          key = "OS";
        }
        {
          type = "command";
          key = "OS Age";
          text = "${osAge}/bin/os-age";
          format = "{}";
        }
        {
          type = "kernel";
          key = "Kernel";
        }
        {
          type = "uptime";
          key = "Uptime";
        }
        {
          type = "packages";
          key = "Pkgs";
        }
        {
          type = "shell";
          key = "Shell";
        }
        {
          type = "wm";
          key = "WM";
        }
        {
          type = "terminal";
          key = "Term";
        }
        {
          type = "cpu";
          key = "CPU";
        }
        {
          type = "gpu";
          key = "GPU";
        }
        {
          type = "memory";
          key = "Mem";
        }
        {
          type = "disk";
          key = "Disk";
          folders = "/";
        }
        "colors"
      ];
    };
  };
}
