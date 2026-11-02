{ runCommand, coreutils, lib, emacs, testSupport, texmacs }:
testSupport.mkErtCheck {
  inherit runCommand coreutils lib emacs testSupport;
  name = "org-texmacs-standard-export-stage-a";
  testFiles = [ ./probe.el ];
  helpers = [ testSupport.common testSupport.native ];
  nativeBuildInputs = [ texmacs ];
  tools = [ "texmacs" ];
  timeout = 110;
  environment.ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
}
