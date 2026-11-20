{ extraArgs }: final_: prev_: {
  org-10pre-texmacs = final_.callPackage (
    { org, texmacs }:
    let
      compatPackages = final_.overrideScope (_: _: { inherit org; });
    in
    compatPackages.callPackage
      (
        {
          lib,
          mkChecks,
          melpaBuild,
          emacsWithPackages,
          citeproc,
          package-lint,
          runCommand,
          coreutils,
          gnutar,
          patch,
          poppler-utils,
          python3,
          org,
          org-roam,
          texmacs,
        }@args:
        assert lib.assertMsg (lib.versionAtLeast org.version "9.8.10") "org-texmacs requires Org >= 9.8.10";
        (import extraArgs.source args).overrideAttrs (
          finalAttrs_: old_: {
            patches = [ ./org-10pre-compat.patch ];
            postPatch = builtins.concatStringsSep " " [
              "substituteInPlace org-texmacs-core.el"
              "--replace-fail"
              "'(defcustom org-texmacs-program \"texmacs\"'"
              "'(defcustom org-texmacs-program \"${lib.getExe' texmacs "texmacs"}\"'"
            ];
            passthru = old_.passthru // {
              tests = old_.passthru.tests // {
                ert-setupfile = compatPackages.callPackage ./tests/ert-setupfile.nix {
                  org-texmacs = finalAttrs_.finalPackage;
                };
              };
            };
          }
        )
      )
      {
        inherit (extraArgs) mkChecks;
        inherit texmacs;
      }
  ) { org = final_.callPackage ./org-source.nix { }; };
}
