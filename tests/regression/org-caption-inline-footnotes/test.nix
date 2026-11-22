{ pkgs, testSupport }:
let
  inherit (pkgs)
    coreutils
    emacsPackages
    lib
    runCommand
    texmacs
    gnutar
    patch
    ;
  inherit (emacsPackages) org;
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
in
if lib.getVersion org != "9.8.10" then
  { }
else
  runCommand "org-texmacs-regression-org-caption-inline-footnotes"
    {
      nativeBuildInputs = [
        coreutils
        texmacs
      ];
      ORG_TEXMACS_TEST_BOOTSTRAP = testSupport.bootstrap;
      ORG_TEXMACS_TEST_HELPERS = builtins.toJSON [
        testSupport.document
        testSupport.native
      ];
      ORG_TEXMACS_TEST_FILES = builtins.toJSON [ ./lisp/caption-inline-footnotes-captions.el ];
      ORG_TEXMACS_TEST_TOOLS = builtins.toJSON [ "texmacs" ];
      ORG_TEXMACS_TEST_STRICT_TOOLS = "1";
      ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
      ORG_TEXMACS_TEST_PATCHED_ORG = patchedOrg;
      ORG_TEXMACS_TEST_PATCHED_PACKAGE = testPackage;
    }
    ''
      export HOME="$TMPDIR/home"
      mkdir -p "$HOME" "$out"
      export ORG_TEXMACS_TEST_NAMES_FILE="$out/test-names.txt"
      set -o pipefail
      timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch --load ${testSupport.runner} 2>&1 | tee "$out/ert.log"
    ''
