{ runCommand, coreutils, lib, emacsPackages, testSupport, texmacs, poppler-utils }:
let organize = builtins.fetchTree { type = "github"; owner = "ren-lingyu"; repo = "org-roam-organize"; rev = "56fdaac6adab06deafc23357aec63ae2a497e09b"; narHash = "sha256-rZBPdTRUmPKrk0JWkF5ukQs9qjPzo6600Vct2P3Ac9A="; };
 emacs = emacsPackages.emacsWithPackages (ep: [ ep.org-texmacs ep.org-roam ep.citeproc ]);
in testSupport.mkErtCheck {
 inherit runCommand coreutils lib emacs testSupport;
 name = "org-texmacs-standard-cite-probe";
 testFiles = [ ./probe.el ./organize.el ]; helpers = [ testSupport.common testSupport.native testSupport.pdf ];
 emacsArgs = [ "-L" "${organize}/lisp" ];
 nativeBuildInputs = [ texmacs poppler-utils ]; tools = [ "texmacs" "pdftotext" ]; timeout = 110;
 environment.ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
}
