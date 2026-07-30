{ pkgs, ... }:

let
  json = pkgs.formats.json { };
  impulseName = "music_balanced";
  impulse = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/shuhaowu/linux-thinkpad-speaker-improvements/2c8360d4cbfd8bc515ebc4561ce3f29650f59bbe/ThinkpadT14Gen6/music_balanced.irs";
    hash = "sha256-vfZAxiXu+LjMk6FX9vrusxATxiUD3ZTYeHHINK8fs2s=";
  };

  devicePrefix = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic";
  speakerDevice = "${devicePrefix}.HiFi__Speaker__sink";
  headphoneDevice = "${devicePrefix}.HiFi__Headphones__sink";
  speakerProfile = "HiFi: Speaker: sink";
  headphoneProfile = "HiFi: Headphones: sink";
  headphoneBands = [
    {
      type = "Lo-shelf";
      frequency = 28.0;
      gain = 4.13;
      q = 0.917;
    }
    {
      type = "Bell";
      frequency = 144.0;
      gain = 0.4;
      q = 4.36;
    }
    {
      type = "Bell";
      frequency = 223.0;
      gain = -3.43;
      q = 0.412;
    }
    {
      type = "Bell";
      frequency = 791.0;
      gain = 2.4;
      q = 1.277;
    }
    {
      type = "Bell";
      frequency = 2335.0;
      gain = -0.9;
      q = 1.414;
    }
    {
      type = "Bell";
      frequency = 2451.0;
      gain = 0.5;
      q = 2.998;
    }
    {
      type = "Bell";
      frequency = 3596.0;
      gain = -3.0;
      q = 2.133;
    }
    {
      type = "Bell";
      frequency = 4868.0;
      gain = 1.6;
      q = 1.826;
    }
  ];
  equalizerChannel = builtins.listToAttrs (builtins.genList (
    index:
    let
      band = builtins.elemAt headphoneBands index;
    in
    {
      name = "band${toString index}";
      value = band // {
        mode = "APO (DR)";
        slope = "x1";
        solo = false;
        mute = false;
        width = 4.0;
      };
    }
  ) (builtins.length headphoneBands));
in
{
  services.easyeffects = {
    enable = true;
    preset = "Laptop Speakers";
    extraPresets = {
      "Laptop Speakers".output = {
        blocklist = [ ];
        plugins_order = [
          "convolver#0"
          "limiter#0"
        ];

        "convolver#0" = {
          bypass = false;
          input-gain = 0.0;
          output-gain = 0.0;
          kernel-name = impulseName;
          ir-width = 100;
          autogain = true;
        };

        "limiter#0" = {
          bypass = false;
          input-gain = 0.0;
          output-gain = 0.0;
          lookahead = 5.0;
          attack = 5.0;
          release = 50.0;
          threshold = -1.0;
          stereo-link = 100.0;
          alr = false;
          gain-boost = false;
        };
      };

      Bypass.output = {
        blocklist = [ ];
        plugins_order = [ ];
      };

      "AUX Headphones".output = {
        blocklist = [ ];
        plugins_order = [ "equalizer#0" ];

        "equalizer#0" = {
          bypass = false;
          input-gain = -5.0;
          output-gain = 0.0;
          mode = "IIR";
          decramp = "Off";
          split-channels = false;
          balance = 0.0;
          pitch-left = 0.0;
          pitch-right = 0.0;
          num-bands = builtins.length headphoneBands;
          left = equalizerChannel;
          right = equalizerChannel;
        };
      };
    };
  };

  xdg.dataFile = {
    "easyeffects/irs/${impulseName}.irs".source = impulse;

    "easyeffects/autoload/output/${speakerDevice}:${speakerProfile}.json".source =
      json.generate "easyeffects-speaker-autoload.json" {
        device = speakerDevice;
        device-description = "Arrow Lake cAVS Speaker";
        device-profile = speakerProfile;
        preset-name = "Laptop Speakers";
      };

    "easyeffects/autoload/output/${headphoneDevice}:${headphoneProfile}.json".source =
      json.generate "easyeffects-headphone-autoload.json" {
        device = headphoneDevice;
        device-description = "Arrow Lake cAVS Headphones";
        device-profile = headphoneProfile;
        preset-name = "AUX Headphones";
      };
  };
}
