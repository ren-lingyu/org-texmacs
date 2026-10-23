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

    perSystem = { config, pkgs, ... } : let

      source = pkgs.lib.fileset.toSource {
        root = ./lisp;
        fileset = pkgs.lib.fileset.unions [
          ./lisp
        ];
      };

      emacsPackages = pkgs.emacsPackagesFor pkgs.emacs31;

      buildPackage = org : emacsPackages.trivialBuild {
        pname = "org-texmacs";
        version = "0.5.0";
        src = source;
        packageRequires = [
          org
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

      emacs = emacsPackages.emacsWithPackages (ps_ : (builtins.concatLists [
        (with ps_; [
          package-lint
        ])
        [ config.packages.default ]
      ]));

    in {

      packages = {
        default = buildPackage emacsPackages.org;
      };

      checks = import ./tests {
        inherit pkgs source emacs emacsPackages buildPackage;
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
