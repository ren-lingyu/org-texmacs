{

  description = "TeXmacs AST integration for Org";

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

    perSystem = { config, pkgs, ... } : let

      source = pkgs.lib.fileset.toSource {
        root = ./.;
        fileset = pkgs.lib.fileset.unions [
          ./org-texmacs.el
          ./org-texmacs-core.el
          ./org-texmacs-ast.el
          ./org-texmacs-document.el
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

      packages = {
        default = emacsPackages.trivialBuild {
          pname = "org-texmacs";
          version = "0.1.0";
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

      checks = import ./tests {
        inherit pkgs source emacs;
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
