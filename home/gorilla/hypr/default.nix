{ config, inputs, pkgs, ... }:

let
  wallpaper = ../../../assets/wallpaper.png;

  hyprKineticScroll = pkgs.stdenv.mkDerivation {
    pname = "hypr-kinetic-scroll";
    version = "unstable-2026-07-05";
    src = inputs.hypr-kinetic-scroll;

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = with pkgs; [
      aquamarine
      hyprland
      hyprcursor
      hyprgraphics
      hyprland-qt-support
      hyprlang
      hyprutils
      libdrm
      libglvnd
      libinput
      libxkbcommon
      lua5_4
      pango
      pixman
      systemd
      wayland
      xcbutilerrors
      xcbutilwm
    ];

    installPhase = ''
      runHook preInstall
      install -Dm755 hypr-kinetic-scroll.so \
        "$out/lib/libhypr-kinetic-scroll.so"
      runHook postInstall
    '';
  };

  osdVolume = pkgs.writeShellApplication {
    name = "osd-volume";
    runtimeInputs = with pkgs; [
      gnugrep
      swayosd
      wireplumber
    ];
    text = ''
      action="''${1:-toggle-mute}"
      case "$action" in
        mic-mute)
          wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
          if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
            exec swayosd-client --custom-message "Microphone muted" --custom-icon microphone-sensitivity-muted-symbolic
          else
            exec swayosd-client --custom-message "Microphone on" --custom-icon audio-input-microphone-symbolic
          fi
          ;;
        mute|toggle-mute)
          exec swayosd-client --output-volume mute-toggle
          ;;
        up)
          exec swayosd-client --output-volume +5 --max-volume 100
          ;;
        down)
          exec swayosd-client --output-volume -5 --max-volume 100
          ;;
      esac
    '';
  };

  osdBrightness = pkgs.writeShellApplication {
    name = "osd-brightness";
    runtimeInputs = with pkgs; [
      brightnessctl
      swayosd
    ];
    text = ''
      case "''${1:-up}" in
        up) exec swayosd-client --brightness +10 --device intel_backlight ;;
        down) exec swayosd-client --brightness -10 --device intel_backlight ;;
      esac
    '';
  };

  screenshotRegion = pkgs.writeShellApplication {
    name = "screenshot-region";
    runtimeInputs = with pkgs; [
      coreutils
      grim
      libnotify
      slurp
      wl-clipboard
    ];
    text = ''
      dir="$HOME/Pictures/Screenshots"
      mkdir -p "$dir"
      file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
      region=$(slurp)
      [ -n "$region" ] || exit 0
      grim -g "$region" "$file"
      wl-copy < "$file"
      notify-send --urgency=low "Screenshot saved" "$file"
    '';
  };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
  };

  home.packages = [
    osdVolume
    osdBrightness
    screenshotRegion
  ];

  services.swayosd = {
    enable = true;
    topMargin = 0.85;
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      "$font" = "JetBrainsMono Nerd Font";

      general = {
        hide_cursor = true;
        grace = 0;
        no_fade_in = false;
        no_fade_out = false;
        disable_loading_bar = true;
      };

      animations = {
        enabled = true;
        bezier = "ease, 0.22, 1, 0.36, 1";
        animation = [
          "fadeIn, 1, 4, ease"
          "fadeOut, 1, 4, ease"
        ];
      };

      auth.fingerprint = {
        enabled = true;
        present_message = "Scanning fingerprint...";
        retry_delay = 250;
      };

      background = [{
        monitor = "";
        path = "${wallpaper}";
        blur_passes = 2;
        blur_size = 6;
        brightness = 0.85;
        contrast = 1.0;
      }];

    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = "";
          path = "${wallpaper}";
          fit_mode = "cover";
        }
      ];
    };
  };

  xdg.configFile."hypr/kinetic-scroll.conf".text = ''
    exec-once = hyprctl plugin load ${hyprKineticScroll}/lib/libhypr-kinetic-scroll.so

    plugin:kinetic-scroll:enabled = 1
    plugin:kinetic-scroll:decel = 0.92
    plugin:kinetic-scroll:min_velocity = 0.5
    plugin:kinetic-scroll:interval_ms = 16
    plugin:kinetic-scroll:delta_multiplier = 1.25
    plugin:kinetic-scroll:disable_in_browser = 1
    plugin:kinetic-scroll:stop_on_target_change = 1
    plugin:kinetic-scroll:disabled_classes =
    plugin:kinetic-scroll:debug = 0
    plugin:kinetic-scroll:stop_on_click = 0
    plugin:kinetic-scroll:stop_on_focus = 0
  '';

  xdg.configFile."hypr/hyprland.conf".source = ./hyprland.conf;
}
