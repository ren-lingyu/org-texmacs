{
  lib,
  runCommand,
  coreutils,
  testSupport,
  emacsPackages,
}:
testSupport.mkErtCheck {
  inherit
    lib
    runCommand
    coreutils
    testSupport
    ;
  emacs = emacsPackages.emacsWithPackages (_: [
    emacsPackages.org-texmacs
    emacsPackages.citeproc
  ]);
  name = "org-texmacs-ert-csl";
  testFiles = [ ./lisp/standard-cite.el ];
  helpers = [
    testSupport.common
    testSupport.csl
  ];
  pure = true;
}
