{
  description = "TeXmacs trees and document sessions for Org";

  inputs = {
    nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs.git?ref=refs/heads/nixpkgs-unstable&shallow=1";
    };
    personal-nixpkgs = {
      url = "git+https://github.com/ren-lingyu/nixpkgs.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    inputs.personal-nixpkgs.lib.mkFlake inputs.nixpkgs
      ({ lib }: rec {
        inherit inputs;
        moduleLocation = __curPos.file;
        llib = inputs.personal-nixpkgs.lib.mergeAttrsRecursive { allowOverrides = false; } [
          { inherit (inputs.personal-nixpkgs.lib) tests packages; }
        ];
        lpkgs = import ./pkgs {
          inherit llib;
          inherit (specialArgs) src;
        };

        specialArgs = {
          src = lib.fileset.toSource {
            root = ./lisp;
            fileset = lib.fileset.unions [ ./lisp ];
          };
        };
      })
      (
        {
          src,
          llib,
          lpkgs,
          config,
          lib,
          ...
        }:
        {
          config = {
            systems = inputs.nixpkgs.lib.systems.flakeExposed;

            flake = {
              overlays = { inherit (lpkgs.overlays) emacsPackages texmacs; };
            };

            perSystem =
              {
                system,
                config,
                pkgs,
                lib,
                ...
              }:
              {
                nixpkgs.overlays = [ lpkgs.overlays.legacy ];

                legacyPackages = pkgs.legacyPackages;

                packages = {
                  org-texmacs = pkgs.emacsPackages.org-texmacs;
                  emacs = pkgs.emacs-with-org-texmacs;
                  texmacs-fandol = pkgs.texmacs-fandol;
                  texmacs-with-gotor-support = pkgs.texmacs-with-gotor-support;
                  texmacs-fandol-with-gotor-support = pkgs.texmacs-fandol-with-gotor-support;
                  org-texmacs-examples = pkgs.org-texmacs-examples;
                };

                checks = import ./tests {
                  inherit src pkgs llib;
                  emacs = pkgs.emacs-with-org-texmacs;
                };

                devShells = {
                  default = pkgs.mkShell {
                    packages = [
                      pkgs.emacs-with-org-texmacs
                      pkgs.texmacs-fandol-with-gotor-support
                    ];
                  };
                };

                treefmt = {
                  flakeCheck = true;
                  settings.excludes = [
                    "*.patch"
                    ".gitignore"
                    "LICENSE"
                    "*.org"
                    "flake.lock"
                  ];
                };
              };
          };
        }
      );
}
