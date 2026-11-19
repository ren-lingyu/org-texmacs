{
  lib,
  src,
  melpaBuild,
  org,
  texmacs,
}:
assert lib.assertMsg (lib.versionAtLeast org.version "9.8.10") "org-texmacs requires Org >= 9.8.10";
melpaBuild (finalAttrs_: {
  inherit src;

  pname = "org-texmacs";
  version = "0.8.0";
  melpaVersion = "0.8.0";

  files = ''(:defaults "org-texmacs-worker.scm")'';

  packageRequires = [ org ];

  turnCompilationWarningToError = true;

  postPatch = builtins.concatStringsSep " " [
    "substituteInPlace org-texmacs-core.el"
    "--replace-fail"
    "'(defcustom org-texmacs-program \"texmacs\"'"
    "'(defcustom org-texmacs-program \"${lib.getExe' texmacs "texmacs"}\"'"
  ];

  meta = {
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
  };
})
