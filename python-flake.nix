{
  description = "Dev shell for large Django project (Python 3.11)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # adjust
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; # or aarch64-linux
      pkgs = import nixpkgs { inherit system; };
      py = pkgs.python311;
    in
    {
      devShells.${system}.default = pkgs.mkShell {

        packages = with pkgs; [
          py
          py.pkgs.pip
          py.pkgs.virtualenv

          # Common build toolchain for Python packages with native extensions
          gcc
          gnumake
          pkg-config

          # Common system libs used by many Python deps (tune as needed)
          openssl
          zlib
          libffi
          readline
          sqlite
          postgresql  
        ];

        # Ensure libstdc++ is discoverable for binary wheels / compiled extensions
        # (manylinux wheels usually bundle what they need, but not always)
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
          pkgs.stdenv.cc.cc.lib
          pkgs.zlib
          pkgs.openssl
          pkgs.libffi
        ];

        # Nice-to-haves: ensure pip builds against Nix-provided headers/libs
        # (helps when pip needs to compile C/C++ extensions)
        NIX_CFLAGS_COMPILE = "-I${pkgs.openssl.dev}/include";
        NIX_LDFLAGS = "-L${pkgs.openssl.out}/lib";

        shellHook = ''
          echo "🐍 Python: $(python --version)"
          echo "Tip: python -m venv .venv && source .venv/bin/activate"
          echo "LD_LIBRARY_PATH includes: ${pkgs.stdenv.cc.cc.lib}/lib"
        '';
      };
    };
}

