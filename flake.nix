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
        # by defining our own texlive distribution, we can trim
        # down the size of the nix store
        latex = (pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-small svg trimspaces catchfile transparent moresize hyphenat
            raleway fontawesome5 pagecolor hardwrap;
        });

        buildInputs = with pkgs; [ latex font-awesome fontconfig ];

        fonts = pkgs.makeFontsConf { fontDirectories = [ pkgs.font-awesome ]; };

        # I would prefer to use a flake input here, but it takes quite a bit to clone this repo.
        nixLogo = pkgs.fetchurl {
          url =
            "https://github.com/NixOS/nixos-artwork/raw/a86492b5338813910e4505b30a8600be2c2a1f4c/logo/white.png";
          sha256 = "0pd45ya86x1z00fb67aqhmmvm7pk50awkmw3bigmhhiwd4lv9n6h";
        };

      in {
        devShell = pkgs.mkShell.override {
          stdenv = pkgs.stdenvNoCC;
        } {
          buildInputs = buildInputs;
          shellHook = "export FONTCONFIG_FILE=${fonts}";
        };

        # we dont need a compiler here, its just latex! :)
        defaultPackage = pkgs.stdenvNoCC.mkDerivation {
          name = "resume";
          nativeBuildInputs = buildInputs;
          src = ./.;
          FONTCONFIG_FILE = fonts;
          buildPhase = ''
            # updmap -user
            substituteInPlace developercv.cls \
              --replace @NIXLOGOPATH@ ${nixLogo}
            xelatex --shell-escape resume.tex
            if [ -d covers ]; then xelatex covers/*; fi
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
