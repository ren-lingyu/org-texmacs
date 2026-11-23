{
  pkgs,
  pdfInspector,
  testSupport,
}:
let
  inherit (pkgs)
    coreutils
    emacsPackages
    lib
    runCommand
    texmacs
    poppler-utils
    python3
    ;
  emacs = emacsPackages.emacsWithPackages (_: [ emacsPackages.org-texmacs ]);
in
runCommand "org-texmacs-integration-pdf-render"
  {
    nativeBuildInputs = [
      coreutils
      texmacs
      poppler-utils
      (python3.withPackages (ps: [ ps.pypdf ]))
    ];
    ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
    ORG_TEXMACS_TEST_PDF_LINKS = pdfInspector;
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME" "$out"
    set -o pipefail
    type texmacs >/dev/null
    type pdftotext >/dev/null
    type pdfinfo >/dev/null
    type pdftohtml >/dev/null
    type python3 >/dev/null
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
              ./lisp/ert-pdf-pdf.el
            ]
        )
      } \
      --funcall ert-run-tests-batch-and-exit 2>&1 | tee "$out/ert.log"
  ''
