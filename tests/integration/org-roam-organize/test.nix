{ pkgs, testSupport }:
let
  inherit (pkgs)
    coreutils
    emacsPackages
    lib
    runCommand
    texmacs
    poppler-utils
    ;
  # Pin the external extension used by this integration check.
  organize = builtins.fetchTree {
    type = "github";
    owner = "ren-lingyu";
    repo = "org-roam-organize";
    rev = "56fdaac6adab06deafc23357aec63ae2a497e09b";
    narHash = "sha256-rZBPdTRUmPKrk0JWkF5ukQs9qjPzo6600Vct2P3Ac9A=";
  };
  emacs = emacsPackages.emacsWithPackages (_: [
    emacsPackages.org-texmacs
    emacsPackages.citeproc
    emacsPackages.org-roam
  ]);
in
runCommand "org-texmacs-integration-org-roam-organize"
  {
    nativeBuildInputs = [
      coreutils
      texmacs
      poppler-utils
    ];
    ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME" "$out"
    set -o pipefail
    type texmacs >/dev/null
    type pdftotext >/dev/null
    timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch -L "${organize}/lisp" \
      ${
        lib.escapeShellArgs (
          lib.concatMap
            (file: [
              "--load"
              "${file}"
            ])
            [
              testSupport.csl
              testSupport.native
              testSupport.pdf
              ./lisp/standard-cite-integration-standard-cite.el
            ]
        )
      } \
      --funcall ert-run-tests-batch-and-exit 2>&1 | tee "$out/ert.log"
  ''
