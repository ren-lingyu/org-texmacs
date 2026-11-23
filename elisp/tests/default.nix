{
  lib,
  mkChecks,
  emacsPackages,
  runCommand,
  coreutils,
  setupfileTest,
}:
let
  emacs = emacsPackages.emacsWithPackages (_: [ emacsPackages.org-texmacs ]);

in
mkChecks {
  root = ./.;
  overlayFile = "test-overlay.nix";
  separator = "-";

  checks = lib.optionalAttrs (setupfileTest != null) {
    ert-setupfile =
      runCommand "org-texmacs-org-10pre-ert-setupfile"
        {
          nativeBuildInputs = [ coreutils ];
          ORG_TEXMACS_TEST_EXPECTED_ORG = emacsPackages.org;
          ORG_TEXMACS_TEST_EXPECTED_PACKAGE = emacsPackages.org-texmacs;
        }
        ''
          export HOME="$TMPDIR/home"
          mkdir -p "$HOME" "$out"
          set -o pipefail
          timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch \
            --load ${lib.escapeShellArg "${setupfileTest}"} \
            --funcall ert-run-tests-batch-and-exit 2>&1 | tee "$out/ert.log"
        '';
  };
  args = {
    inherit
      lib
      runCommand
      coreutils
      emacsPackages
      emacs
      ;
  };
}
