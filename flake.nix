{
  description = "A Nix-flake-based Python development environment";

  inputs = { 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      supportedSystems = [ "x86_64-linux" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            python311
            poetry
            python311Packages.virtualenv
            python311Packages.python-magic
            python311Packages.flask
          ]; 

          LD_LIBRARY_PATH = lib.makeLibraryPath [
            pkgs.stdenv.cc.cc
            pkgs.zlib
          ];

          buildInputs = with pkgs; [
            stdenv.cc.cc
          ];

          shellHook = with pkgs; ''
            echo
            echo 
            echo "`${python311}/bin/python3 --version` environment activated"
            python -m venv ./.venv
            . ./.venv/bin/activate
            echo "venv activated"
            unset SOURCE_DATE_EPOCH
          '';
        };
      });
    };
}

