{

  description = "TeXmacs trees and document sessions for Org";

  inputs = {
    nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs.git?ref=refs/heads/nixpkgs-unstable&shallow=1";
    };
    flake-parts = {
      url = "git+https://github.com/hercules-ci/flake-parts.git?ref=refs/heads/main&shallow=1";
    };
    treefmt-nix = {
      url = "git+https://github.com/numtide/treefmt-nix.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    personal-nixpkgs = {
      url = "git+https://github.com/ren-lingyu/nixpkgs?ref=refs/heads/main&shallow=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
  };

  outputs = { self, ... }@inputs : inputs.flake-parts.lib.mkFlake { inherit inputs; } {

    imports = [ inputs.treefmt-nix.flakeModule ];

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

      treefmt = {
        flakeFormatter = true;
        flakeCheck = false;
        enableDefaultExcludes = false;
        projectRootFile = builtins.baseNameOf __curPos.file;
        settings.excludes = [
          ".gitignore"
          "LICENSE"
          "README.org"
          "flake.lock"
        ];
        programs = {
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt;
            width = 100;
            indent = 2;
            strict = true;
          };
        };
      };

    };

  };

}
