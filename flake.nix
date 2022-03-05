{
  description = "wlroots tinywl c implementation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };

    nixpkgs-wayland = { url = "github:nix-community/nixpkgs-wayland"; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachSystem
      (with flake-utils.lib.system; [
        x86_64-linux

      ])
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

          systemLibraries = with pkgs; [
            xorg.libX11
            xorg.libXinerama
            xorg.libXcursor
            xorg.libXrandr
            xorg.libXi
            xorg.libXxf86vm
            xorg.libXext
          ];

          dynamicLibraries = with pkgs; [
            vulkan-loader
            wlroots
            libxkbcommon
            wayland-scanner
            wayland-protocols
            wayland
            pixman
            udev
          ];

          packageName = "tinywl";

        in
        {

          devShells.dev = pkgs.mkShell {
            buildInputs = with pkgs; [
              gnumake

              pkg-config
              wayland-scanner
              libxkbcommon
              pixman
              udev
              wayland
              wayland-protocols
              inputs.nixpkgs-wayland.packages.${system}.wlroots
            ]; # ++ systemLibraries ++ dynamicLibraries;

            shellHook = ''
              [ $STARSHIP_SHELL ] && exec $STARSHIP_SHELL
            '';

            # LD_LIBRARY_PATH = pkgs.lib.strings.makeLibraryPath dynamicLibraries;

            CURRENT_PROJECT = packageName;
          };

          devShell = self.devShells.${system}.dev;

        });

}



















