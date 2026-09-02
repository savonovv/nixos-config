{ hostName, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting

      set -gx EDITOR nvim
      set -gx VISUAL nvim
      set -gx PAGER less
      set -gx MANPAGER "nvim +Man!"

      fastfetch
    '';

    shellAliases = {
      ls = "eza --icons";
      ll = "eza -lah --icons --git";
      tree = "eza --tree --icons";
      cat = "bat";
      cl = "clear && fastfetch";
      vim = "nvim";
      t = "tmux";
      ta = "tmux attach-session";
      tls = "tmux list-sessions";
      tn = "tmux new-session -s";
      tk = "tmux kill-session -t";
      cc = "opencode -c";
      c = "opencode";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#${hostName}";
      update-system = "nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#${hostName}";
      rollback = "sudo nixos-rebuild switch --rollback";
    };

    plugins = [
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
    ];
  };

    programs.starship = {
      enable = true;
      enableFishIntegration = true;

    settings = {
      add_newline = false;
      palette = "kanagawa";

      format = "$username$hostname$directory$git_branch$git_status$git_state$cmd_duration$line_break$character";

      palettes.kanagawa = {
        sumi_ink = "#1f1f28";
        fuji_white = "#dcd7ba";
        fuji_gray = "#727169";
        crystal_blue = "#7e9cd8";
        spring_blue = "#7fb4ca";
        spring_green = "#98bb6c";
        oni_violet = "#957fb8";
        carp_yellow = "#e6c384";
        surimi_orange = "#ffa066";
        wave_red = "#e46876";
      };

      username = {
        show_always = false;
        format = "[$user]($style) ";
        style_user = "bold carp_yellow";
      };

      hostname = {
        ssh_only = true;
        format = "[@$hostname]($style) ";
        style = "bold spring_blue";
      };

      directory = {
        format = "[󰉋 $path]($style) ";
        style = "bold crystal_blue";
        read_only = " 󰌾";
        truncation_length = 4;
        truncate_to_repo = false;
      };

      git_branch = {
        format = "[ $branch]($style) ";
        style = "bold oni_violet";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "bold spring_blue";
        conflicted = "=";
        ahead = "⇡$count";
        behind = "⇣$count";
        diverged = "⇕⇡$ahead_count⇣$behind_count";
        untracked = "?";
        stashed = "≡";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      git_state = {
        format = "([$state( $progress_current/$progress_total)]($style) )";
        style = "bold surimi_orange";
      };

      cmd_duration = {
        format = "[󰔟 $duration]($style) ";
        style = "fuji_gray";
        min_time = 500;
      };

      character = {
        success_symbol = "[❯](bold spring_green)";
        error_symbol = "[❯](bold wave_red)";
        vimcmd_symbol = "[❮](bold oni_violet)";
      };
    };
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
