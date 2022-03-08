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

          nativeBuildInputs = with pkgs; [ pkg-config wayland-scanner ];

          buildInputs = with pkgs; [
            libxkbcommon
            pixman
            udev
            wayland
            wayland-protocols
            inputs.nixpkgs-wayland.packages.${system}.wlroots
          ];

          packageName = "tinywl";

        in
        {

          packages.${packageName} = pkgs.stdenv.mkDerivation {
            pname = packageName;
            version = "0.15.1";
            src = ./.;

            nativeBuildInputs = nativeBuildInputs;
            buildInputs = buildInputs;

            installPhase = ''
              runHook preInstall

              mkdir -p $out/bin
              cp tinywl $out/bin

              runHook postInstall
            '';
          };

          devShells.dev = pkgs.mkShell {
            packages = with pkgs; [
              clang
              clang-tools
              cppcheck
              # ccls

              rnix-lsp
            ];

            buildInputs = with pkgs; [
              gnumake
            ] ++ nativeBuildInputs ++ buildInputs;

            shellHook = ''
              [ $STARSHIP_SHELL ] && exec $STARSHIP_SHELL
            '';
            # LD_LIBRARY_PATH = pkgs.lib.strings.makeLibraryPath dynamicLibraries;
            CURRENT_PROJECT = packageName;
          };

          defaultPackage = self.packages.${system}.${packageName};
          devShell = self.devShells.${system}.dev;

        });

}

