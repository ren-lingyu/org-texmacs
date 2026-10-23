{ runCommand, coreutils, lib, gnutar, patch, texmacs,
  emacsPackages, buildPackage, testSupport }:
let
  # ELPA unpacks its input during installPhase, not unpackPhase.
  patchedSource = assert lib.getVersion emacsPackages.org == "9.8.10";
    runCommand "org-9.8.10.tar" {
      nativeBuildInputs = [ gnutar patch ];
    } ''
      tar -xf ${emacsPackages.org.src}
      patch --batch --fuzz=0 -d org-9.8.10 -p1 < ${./org-caption-inline-footnote.patch}
      tar --sort=name --mtime=@1 --owner=0 --group=0 --numeric-owner \
        -cf "$out" org-9.8.10
    '';
  org = emacsPackages.org.overrideAttrs (_: { src = patchedSource; });
  testPackage = buildPackage org;
  emacs = emacsPackages.emacsWithPackages (_: [ testPackage ]);
  testFiles = [
    ./lisp/captions.el
  ];
in runCommand "org-texmacs-caption-inline-footnotes" {
  nativeBuildInputs = [ coreutils texmacs ];
  ORG_TEXMACS_TEST_BOOTSTRAP = testSupport.bootstrap;
  ORG_TEXMACS_TEST_HELPERS = builtins.toJSON [ testSupport.common testSupport.native ];
  ORG_TEXMACS_TEST_FILES = builtins.toJSON testFiles;
  ORG_TEXMACS_TEST_TOOLS = builtins.toJSON [ "texmacs" ];
  ORG_TEXMACS_TEST_STRICT_TOOLS = "1";
  ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
  ORG_TEXMACS_TEST_PATCHED_ORG = org;
  ORG_TEXMACS_TEST_PATCHED_PACKAGE = testPackage;
} ''
  export HOME="$TMPDIR/home"
  mkdir -p "$HOME" "$out"
  export ORG_TEXMACS_TEST_NAMES_FILE="$out/test-names.txt"
  set +e
  timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch \
    --load ${testSupport.runner} > "$out/ert.log" 2>&1
  status=$?
  set -e
  cat "$out/ert.log"
  exit "$status"
''
