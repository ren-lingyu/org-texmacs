{
  description = "Org mathematical-document ASTs with native TeXmacs STM";

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
          inherit (specialArgs) source;
        };
        specialArgs = {
          source = ./elisp;
        };
      })
      (
        {
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
                  inherit (pkgs.emacsPackages) org-texmacs org-10pre-texmacs;
                  emacs = pkgs.emacs-with-org-texmacs;
                  texmacs-fandol = pkgs.texmacs-fandol;
                  texmacs-with-gotor-support = pkgs.texmacs-with-gotor-support;
                  texmacs-fandol-with-gotor-support = pkgs.texmacs-fandol-with-gotor-support;
                  org-texmacs-examples = pkgs.org-texmacs-examples;
                };

                checks = import ./tests {
                  inherit lib llib;
                  packages = pkgs.legacyPackages;
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
                    "LICENSE"
                    "flake.lock"
                  ];
                };
              };
          };
        }
      );
}
