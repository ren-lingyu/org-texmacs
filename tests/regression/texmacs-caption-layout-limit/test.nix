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
  emacs = emacsPackages.emacsWithPackages (_: [ emacsPackages.org-texmacs ]);
in
if lib.getVersion texmacs != "2.1.5" then
  { }
else
  runCommand "org-texmacs-regression-texmacs-caption-layout-limit"
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
      timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch \
        ${
          lib.escapeShellArgs (
            lib.concatMap
              (file: [
                "--load"
                "${file}"
              ])
              [
                testSupport.document
                testSupport.native
                testSupport.pdf
                ./lisp/ert-pdf-document.el
              ]
          )
        } \
        --funcall ert-run-tests-batch-and-exit 2>&1 | tee "$out/ert.log"
    ''
