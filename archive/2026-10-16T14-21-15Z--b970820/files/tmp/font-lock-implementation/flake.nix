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
          ./org-texmacs-font-lock.el
          ./org-texmacs-worker.el
          ./org-texmacs-worker.scm
          ./README.org
          ./LICENSE
        ];
      };

      emacsPackages = pkgs.emacsPackagesFor pkgs.emacs31;

      plainEmacs = emacsPackages.emacsWithPackages (ps: [ ps.org ]);
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

      checks = (import ./tests {
        inherit pkgs source emacs;
      }) // {
        baseline = pkgs.runCommand "org-texmacs-font-lock-baseline" {
          nativeBuildInputs = [ plainEmacs ];
          FONT_LOCK_TESTS = ./tests/ert/ert.el;
        } ''
          mkdir -p "$TMPDIR/home" "$out"
          export HOME="$TMPDIR/home"
          emacs -Q --batch -L ${./baseline} --load ${./baseline.el} > "$out/run.log" 2>&1 || { cat "$out/run.log"; exit 1; }
          cat "$out/run.log"
        '';
        focused = pkgs.runCommand "org-texmacs-font-lock-focused" {
          nativeBuildInputs = [ emacs ];
        } ''
          mkdir -p "$TMPDIR/home" "$out"
          export HOME="$TMPDIR/home"
          emacs -Q --batch --load ${./tests/ert/ert.el} --eval "(ert-run-tests-batch-and-exit \"^org-texmacs-font-lock-\")" > "$out/run.log" 2>&1 || { cat "$out/run.log"; exit 1; }
          cat "$out/run.log"
        '';
        performance = pkgs.runCommand "org-texmacs-font-lock-performance" {
          nativeBuildInputs = [ emacs ];
        } ''
          mkdir -p "$TMPDIR/home" "$out"
          export HOME="$TMPDIR/home"
          export TIMING_OUTPUT="$out"
          emacs -Q --batch --load ${./performance.el} > "$out/run.log" 2>&1 || { cat "$out/run.log"; exit 1; }
          cat "$out/run.log"
        '';
      };

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
