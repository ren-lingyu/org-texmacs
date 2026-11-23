{
  lib,
  runCommand,
  coreutils,
  emacs,
}:
runCommand "org-texmacs-ert-core" { nativeBuildInputs = [ coreutils ]; } ''
  export HOME="$TMPDIR/home"
  mkdir -p "$HOME" "$out"
  set -o pipefail
  timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch \
    ${
      lib.escapeShellArgs (
        lib.concatMap
          (file: [
            "--load"
            "${file}"
          ])
          [
            ./support.el
            ./lisp/bibliography.el
            ./lisp/document.el
            ./lisp/editing.el
            ./lisp/fragment-object.el
            ./lisp/frontend.el
            ./lisp/metadata.el
            ./lisp/model-inspect.el
            ./lisp/model-parser.el
            ./lisp/model-serialization.el
            ./lisp/model-transform.el
            ./lisp/model.el
            ./lisp/native-cite-default.el
            ./lisp/native-cite-source.el
            ./lisp/native-cite.el
            ./lisp/pdf.el
            ./lisp/preprocess.el
            ./lisp/serialization.el
            ./lisp/session.el
            ./lisp/source.el
            ./lisp/special-blocks.el
            ./lisp/standard-cite.el
            ./lisp/standard-context.el
            ./lisp/standard-export.el
            ./lisp/standard-frontend.el
            ./lisp/standard-source.el
            ./lisp/worker.el
          ]
      )
    } \
    --funcall ert-run-tests-batch-and-exit 2>&1 | tee "$out/ert.log"
''
