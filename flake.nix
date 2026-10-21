{
  description = "Ayu GTK theme — Nix packaging with NixOS and Home Manager modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "i686-linux"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system: f (import nixpkgs { inherit system; })
        );
    in
    {
      packages = forAllSystems (
        pkgs:
        rec {
          ayu-theme = pkgs.callPackage ./nix/package.nix { };
          default = ayu-theme;
        }
      );

      overlays.default = final: _prev: {
        ayu-theme = final.callPackage ./nix/package.nix { };
      };

      nixosModules = {
        ayu-theme = ./nix/nixos-module.nix;
        default = self.nixosModules.ayu-theme;
      };

      homeModules = {
        ayu-theme = ./nix/home-module.nix;
        default = self.homeModules.ayu-theme;
      };

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            autoconf
            automake
            pkg-config
            sassc
            gtk3
            gtk4
            nodejs
            gnumake
          ];
          shellHook = ''
            echo "ayu-theme dev shell — build with: ./autogen.sh --prefix=/usr && make install"
          '';
        };
      });

      checks = forAllSystems (
        pkgs: {
          ayu-theme = self.packages.${pkgs.system}.ayu-theme;
        }
      );
    };
}
