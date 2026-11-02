{ runCommand, coreutils, lib, emacs, testSupport }:
testSupport.mkErtCheck {
  inherit runCommand coreutils lib emacs testSupport;
  name = "org-texmacs-standard-query-probe";
  testFiles = [ ./probe.el ]; helpers = [ testSupport.common ]; timeout = 110;
}
