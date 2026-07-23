{ ... }:

{
  services.keyd = {
    enable = true;

    keyboards.default = {
      ids = [ "*" ];

      extraConfig = ''
        [global]
        overload_tap_timeout = 1000

        [main]
        # HHKB-style Control position; grave provides Escape.
        capslock = layer(control)

        grave = esc
        rightalt = layer(nav)

        [control:C]
        h = left
        j = down
        k = up
        l = right

        comma = previoussong
        dot = nextsong
        slash = playpause

        [nav]
        h = left
        j = down
        k = up
        l = right

        comma = previoussong
        dot = nextsong
        slash = playpause

        [shift]
        grave = ~

        [alt]
        grave = `
      '';
    };
  };
}
