{
  description = "Hidamari - Video wallpaper for Linux (with compat and default versions)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          # Default version (latest)
          hidamari = pkgs.callPackage ./default.nix { };
          default = self.packages.${system}.hidamari;
          
          # Compatibility version (older or alternative config)
          hidamari-compat = pkgs.callPackage ./compat.nix { };
          compat = self.packages.${system}.hidamari-compat;
        };

        apps = {
          # Default app
          hidamari = flake-utils.lib.mkApp {
            drv = self.packages.${system}.hidamari;
            name = "hidamari";
          };
          default = self.apps.${system}.hidamari;
          
          # Compat app
          hidamari-compat = flake-utils.lib.mkApp {
            drv = self.packages.${system}.hidamari-compat;
            name = "hidamari";
          };
          compat = self.apps.${system}.hidamari-compat;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nix-prefetch-git
            nix-prefetch-github
          ];
        };
      });
}
