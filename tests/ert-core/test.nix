{
  runCommand,
  coreutils,
  lib,
  emacs,
  testSupport,
}:
let
  testFiles = [
    ./lisp/bibliography.el
    ./lisp/metadata.el
    ./lisp/document.el
    ./lisp/editing.el
    ./lisp/frontend.el
    ./lisp/preprocess.el
    ./lisp/source.el
    ./lisp/special-blocks.el
    ./lisp/worker.el
  ];
in
testSupport.mkErtCheck {
  inherit runCommand coreutils lib emacs testSupport testFiles;
  name = "org-texmacs-ert-core";
  helpers = [
    testSupport.common
    testSupport.native
  ];
}
