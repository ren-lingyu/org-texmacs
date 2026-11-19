{
  runCommand,
  coreutils,
  lib,
  gnutar,
  patch,
  texmacs,
  emacsPackages,
  testSupport,
}:
let
  inherit (emacsPackages) org;

  # ELPA unpacks its input during installPhase, not unpackPhase.
  patchedSource =
    assert lib.getVersion org == "9.8.10";
    runCommand "org-9.8.10.tar"
      {
        nativeBuildInputs = [
          gnutar
          patch
        ];
      }
      ''
        tar -xf ${org.src}
        patch --batch --fuzz=0 -d org-9.8.10 -p1 < ${./org-caption-inline-footnote.patch}
        tar --sort=name --mtime=@1 --owner=0 --group=0 --numeric-owner \
          -cf "$out" org-9.8.10
      '';
  patchedOrg = org.overrideAttrs (_: {
    src = patchedSource;
  });
  testPackage = emacsPackages.org-texmacs.overrideAttrs { packageRequires = [ patchedOrg ]; };
  emacs = emacsPackages.emacsWithPackages (_: [ testPackage ]);
  testFiles = [ ./lisp/captions.el ];
in
testSupport.mkErtCheck {
  inherit
    runCommand
    coreutils
    lib
    emacs
    testSupport
    testFiles
    ;
  name = "org-texmacs-caption-inline-footnotes";
  nativeBuildInputs = [ texmacs ];
  helpers = [
    testSupport.common
    testSupport.native
  ];
  tools = [ "texmacs" ];
  environment = {
    ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
    ORG_TEXMACS_TEST_PATCHED_ORG = patchedOrg;
    ORG_TEXMACS_TEST_PATCHED_PACKAGE = testPackage;
  };
}
