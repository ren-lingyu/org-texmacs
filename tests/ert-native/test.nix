{
  runCommand,
  coreutils,
  lib,
  emacs,
  testSupport,
  texmacs,
}:
let
  testFiles = [
    ./lisp/bibliography.el
    ./lisp/document.el
    ./lisp/editing.el
    ./lisp/examples.el
    ./lisp/frontend.el
    ./lisp/preprocess.el
    ./lisp/serialization.el
    ./lisp/session.el
    ./lisp/source.el
    ./lisp/special-blocks.el
    ./lisp/worker.el
  ];
in
testSupport.mkErtCheck {
  inherit runCommand coreutils lib emacs testSupport testFiles;
  name = "org-texmacs-ert-native";
  nativeBuildInputs = [ texmacs ];
  helpers = [
    testSupport.common
    testSupport.native
  ];
  tools = [ "texmacs" ];
  environment = {
    ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
  };
}
