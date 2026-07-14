{ config, pkgs, ... }:

let
  batteryNotify = pkgs.writeShellApplication {
    name = "battery-notify";
    runtimeInputs = with pkgs; [
      coreutils
      libnotify
    ];
    text = ''
      battery=/sys/class/power_supply/BAT0
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/battery-notify"
      state_file="$state_dir/last-threshold"

      [ -r "$battery/capacity" ] && [ -r "$battery/status" ] || exit 0

      capacity=$(<"$battery/capacity")
      status=$(<"$battery/status")
      mkdir -p "$state_dir"

      if [ "$status" != "Discharging" ] || [ "$capacity" -ge 50 ]; then
        printf '50\n' > "$state_file"
        exit 0
      fi

      last=50
      [ ! -r "$state_file" ] || last=$(<"$state_file")
      threshold=

      for level in 40 30 20 10; do
        if [ "$capacity" -le "$level" ] && [ "$last" -gt "$level" ]; then
          threshold=$level
        fi
      done

      [ -n "$threshold" ] || exit 0

      urgency=normal
      [ "$threshold" -gt 20 ] || urgency=critical
      notify-send --urgency="$urgency" \
        --icon=battery-caution-symbolic \
        "Battery at ''${capacity}%" \
        "Connect the charger soon."
      printf '%s\n' "$threshold" > "$state_file"
    '';
  };
in
{
  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font 11";
      background-color = "#1f1f28f0";
      text-color = "#dcd7ba";
      border-color = "#54546df0";
      progress-color = "over #2d4f67";
      border-size = 2;
      border-radius = 6;
      padding = 10;
      default-timeout = 5000;
      ignore-timeout = true;
      width = 420;
      height = 110;
      outer-margin = 20;
      icons = true;
      max-icon-size = 36;
      markup = true;
      anchor = "top-right";
      layer = "overlay";

      "urgency=low".border-color = "#727169f0";
      "urgency=high" = {
        border-color = "#e82424f0";
        default-timeout = 0;
      };
    };
  };

  programs.vicinae = {
    enable = true;
    systemd.enable = true;

    settings = {
      font = {
        rendering = "qt";
        normal = {
          family = "JetBrainsMono Nerd Font";
          size = 10.5;
        };
      };

      theme = {
        light.name = "vicinae-light";
        dark.name = "kanagawa";
      };

      launcher_window = {
        opacity = 0.9;
        client_side_decorations = {
          enabled = true;
          rounding = 6;
          border_width = 2;
        };
        blur.enabled = true;
      };

      providers = {
        clipboard.preferences = {
          encryption = true;
          eraseOnStartup = false;
          ignorePasswords = true;
          monitoring = true;
        };
        developer.enabled = false;
        font.enabled = false;
        theme.enabled = false;
        wm.enabled = false;
      };
    };

    themes.kanagawa = {
      meta = {
        version = 1;
        name = "Kanagawa";
        description = "Kanagawa Wave palette";
        variant = "dark";
        inherits = "vicinae-dark";
      };
      colors = {
        core = {
          background = "#1f1f28";
          foreground = "#dcd7ba";
          secondary_background = "#16161d";
          border = "#54546d";
          accent = "#7e9cd8";
        };
        accents = {
          blue = "#7e9cd8";
          green = "#98bb6c";
          magenta = "#957fb8";
          orange = "#ffa066";
          purple = "#938aa9";
          red = "#e82424";
          yellow = "#e6c384";
          cyan = "#7aa89f";
        };
      };
    };
  };

  home.packages = [
    batteryNotify
    pkgs.polkit_gnome
  ];

  systemd.user.services.polkit-gnome = {
    Unit = {
      Description = "Polkit authentication agent";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };

  systemd.user.services.battery-notify = {
    Unit.Description = "Notify at low battery thresholds";
    Service = {
      Type = "oneshot";
      ExecStart = "${batteryNotify}/bin/battery-notify";
    };
  };

  systemd.user.timers.battery-notify = {
    Unit.Description = "Check battery level periodically";
    Timer = {
      OnBootSec = "2m";
      OnUnitActiveSec = "1m";
      Unit = "battery-notify.service";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
