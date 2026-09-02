{
  description = "gorilla's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hypr-kinetic-scroll = {
      url = "github:savonovv/hypr-kinetic-scroll";
      flake = false;
    };

    opencode.url = "github:anomalyco/opencode/03bff6500abd09fc469d59e5bd4143d3eb053a94";
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    ...
  }: {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs;
        hostName = "laptop";
        isLaptop = true;
        username = "gorilla";
      };

      modules = [
        ./hosts/laptop/configuration.nix

        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-backup";
          home-manager.extraSpecialArgs = {
            inherit inputs;
            hostName = "laptop";
            isLaptop = true;
            username = "gorilla";
          };

          home-manager.users.gorilla = import ./home/gorilla/home.nix;
        }
      ];
    };

    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs;
        hostName = "desktop";
        isLaptop = false;
        username = "gorilladesk";
      };

      modules = [
        ./hosts/desktop/configuration.nix

        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-backup";
          home-manager.extraSpecialArgs = {
            inherit inputs;
            hostName = "desktop";
            isLaptop = false;
            username = "gorilladesk";
          };

          home-manager.users.gorilladesk = {
            imports = [ ./home/gorilla/home.nix ];
            programs.hyprlock.settings.auth.fingerprint.enabled = nixpkgs.lib.mkForce false;
          };
        }
      ];
    };
  };
}
