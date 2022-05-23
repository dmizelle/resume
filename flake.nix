{
  description = "Devon Mizelle's Resume";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/master";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        buildInputs = with pkgs; [
          texlive.combined.scheme-full
          font-awesome
          fontconfig
          inkscape
        ];
        fonts = pkgs.makeFontsConf {
          fontDirectories = [
            pkgs.font-awesome
          ];
        };
          nixLogo = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/9ba74f81ffeec7e88bc95b3ddf3509e9a8a97587/logo/white.svg";
            sha256 = "1k3ic1b1fmsar8fhms192vfyszx4xivdpak0f49zd2xh5pmabp8i";
          };
      in {
        devShell = pkgs.mkShell {
          buildInputs = buildInputs;
          shellHook = "export FONTCONFIG_FILE=${fonts}";
        };

        defaultPackage = pkgs.stdenv.mkDerivation {
          name = "resume";
          nativeBuildInputs = buildInputs;
          src = ./.;
          FONTCONFIG_FILE = fonts;
          buildPhase = ''
            # updmap -user
            substituteInPlace developercv.cls \
              --replace @NIXLOGOPATH@ ${nixLogo}
            xelatex --shell-escape resume.tex
            ls -lah covers/*
            xelatex covers/*
          '';
          installPhase = ''
            mkdir $out
            mv *.pdf $out/
          '';
        };

        meta = with pkgs.lib; {
          description = "Devon Mizelle's Resume";
          license = licenses.mit;
        };
      });
}
