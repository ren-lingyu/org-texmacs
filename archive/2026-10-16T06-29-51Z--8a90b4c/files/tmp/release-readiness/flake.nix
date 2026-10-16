{

  description = "TeXmacs trees and document sessions for Org";

  inputs = {
    nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs.git?ref=refs/heads/nixpkgs-unstable&shallow=1";
    };
    flake-parts = {
      url = "git+https://github.com/hercules-ci/flake-parts.git?ref=refs/heads/main&shallow=1";
    };
  };

  outputs = { self, ... }@inputs : inputs.flake-parts.lib.mkFlake { inherit inputs; } {

    systems = inputs.nixpkgs.lib.systems.flakeExposed;

    perSystem = { config, pkgs, system, ... } : let

      source = pkgs.lib.fileset.toSource {
        root = ./.;
        fileset = pkgs.lib.fileset.unions [
          ./org-texmacs.el
          ./ox-texmacs.el
          ./org-texmacs-core.el
          ./org-texmacs-bibliography.el
          ./org-texmacs-preprocess.el
          ./org-texmacs-context.el
          ./org-texmacs-ast.el
          ./org-texmacs-document.el
          ./org-texmacs-input.el
          ./org-texmacs-session.el
          ./org-texmacs-source.el
          ./org-texmacs-fragment.el
          ./org-texmacs-worker.el
          ./org-texmacs-worker.scm
          ./README.org
          ./LICENSE
        ];
      };

      emacsPackages = pkgs.emacsPackagesFor pkgs.emacs31;

      emacs = emacsPackages.emacsWithPackages (ps_ : (builtins.concatLists [
        (with ps_; [
          package-lint
        ])
        [ config.packages.default ]
      ]));

    in {

      _module.args.pkgs = inputs.nixpkgs.legacyPackages.${system}.extend (final : prev : {
        fetchurl = args : prev.fetchurl (let
          rewrite = builtins.replaceStrings [
            "https://elpa.gnu.org/packages/"
          ] [
            "https://mirrors.ustc.edu.cn/elpa/gnu/"
          ];
          urls = if args ? urls then
            args.urls
          else if args ? url then
            [ args.url ]
          else
            null;
        in if urls == null then
          args
        else
          (builtins.removeAttrs args [ "url" "urls" ]) // {
            urls = builtins.map rewrite urls;
          }
        );
      });

      packages = {
        default = emacsPackages.trivialBuild {
          pname = "org-texmacs";
          version = "0.4.0";
          src = source;
          packageRequires = [
            emacsPackages.org
          ];
          turnCompilationWarningToError = true;
          postPatch = builtins.concatStringsSep " " [
            "substituteInPlace org-texmacs-core.el"
            "--replace-fail"
            "'(defcustom org-texmacs-program \"texmacs\"'"
            "'(defcustom org-texmacs-program \"${pkgs.lib.getExe' pkgs.texmacs "texmacs"}\"'"
          ];
          postInstall = "install -m644 org-texmacs-worker.scm \"$out/share/emacs/site-lisp/\"";
        };
      };

      checks.probes = pkgs.runCommand "org-texmacs-release-readiness-probes" {
        nativeBuildInputs = [ emacs pkgs.texmacs pkgs.poppler-utils pkgs.python3 ];
        ORG_TEXMACS_TEST_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
        ORG_TEXMACS_TEST_README = ./README.org;
        TEXMACS_PACKAGE = "${pkgs.texmacs}";
      } ''
        mkdir -p "$TMPDIR/home" "$out"
        export HOME="$TMPDIR/home"
        export PROBE_OUTPUT="$out"
        emacs -Q --batch --load ${./tests/ert/ert.el} --load ${./probes.el} 2>&1 | tee "$out/run.log"
        for pdf in "$out"/*.pdf; do
          pdftotext -enc UTF-8 "$pdf" "''${pdf%.pdf}.txt"
          pdftotext -bbox "$pdf" "''${pdf%.pdf}.html"
          pdfinfo -url "$pdf" > "''${pdf%.pdf}-urls.txt"
          pdffonts "$pdf" > "''${pdf%.pdf}-fonts.txt"
          pdftohtml -xml -i -stdout "$pdf" > "''${pdf%.pdf}-text.xml" 2>/dev/null
        done
      '';

      checks.comparisons = pkgs.runCommand "org-texmacs-release-readiness-comparisons" {
        nativeBuildInputs = [ emacs pkgs.texmacs pkgs.poppler-utils pkgs.python3 ];
        ORG_TEXMACS_TEST_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
        ORG_TEXMACS_TEST_README = ./README.org;
        FIRST_PROBE = "${config.checks.probes}";
        TEXMACS_PACKAGE = "${pkgs.texmacs}";
      } ''
        mkdir -p "$TMPDIR/home" "$out"
        export HOME="$TMPDIR/home"
        export PROBE_OUTPUT="$out"
        emacs -Q --batch --load ${./tests/ert/ert.el} --load ${./comparisons.el} 2>&1 | tee "$out/run.log"
        for pdf in "$out"/*.pdf; do
          pdftotext -enc UTF-8 "$pdf" "''${pdf%.pdf}.txt"
          pdftotext -bbox "$pdf" "''${pdf%.pdf}.html"
          pdfinfo -url "$pdf" > "''${pdf%.pdf}-urls.txt"
          pdffonts "$pdf" > "''${pdf%.pdf}-fonts.txt"
        done
      '';

      checks.boundaries = pkgs.runCommand "org-texmacs-release-readiness-boundaries" {
        nativeBuildInputs = [ emacs pkgs.texmacs ];
        ORG_TEXMACS_TEST_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
        ORG_TEXMACS_TEST_README = ./README.org;
      } ''
        mkdir -p "$TMPDIR/home" "$out"
        export HOME="$TMPDIR/home"
        export PROBE_OUTPUT="$out"
        emacs -Q --batch --load ${./tests/ert/ert.el} --load ${./boundaries.el} 2>&1 | tee "$out/run.log"
      '';

      devShells = {
        default = pkgs.mkShell {
          packages = [
            emacs
            pkgs.texmacs
          ];
        };
      };

    };

  };

}
