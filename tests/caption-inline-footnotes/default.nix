{ pkgs, source, emacsPackages, buildPackage } : let

  # ELPA's installer unpacks its input during installPhase, not unpackPhase.
  patchedSource = assert pkgs.lib.getVersion emacsPackages.org == "9.8.10";
    pkgs.runCommand "org-9.8.10.tar" {
      nativeBuildInputs = [ pkgs.gnutar pkgs.patch ];
    } ''
      tar -xf ${emacsPackages.org.src}
      patch --batch --fuzz=0 -d org-9.8.10 -p1 < ${./org-caption-inline-footnote.patch}
      tar --sort=name --mtime=@1 --owner=0 --group=0 --numeric-owner \
        -cf "$out" org-9.8.10
    '';

  org = emacsPackages.org.overrideAttrs (_ : { src = patchedSource; });

  testPackage = buildPackage org;

  emacs = emacsPackages.emacsWithPackages (_ : [ testPackage ]);

in pkgs.runCommand "org-texmacs-caption-inline-footnotes" {
  nativeBuildInputs = [ emacs pkgs.texmacs pkgs.poppler-utils ];
  ORG_TEXMACS_TEST_PATCHED_ORG = "${org}";
  ORG_TEXMACS_TEST_PATCHED_PACKAGE = "${testPackage}";
  ORG_TEXMACS_TEST_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
  ORG_TEXMACS_TEST_README = "${../../README.org}";
} ''
  emacs -Q --batch --load ${../ert/ert.el} --load ${./ert.el} \
    --eval '(ert-run-tests-batch-and-exit "^org-texmacs-caption-patched-")'
  touch "$out"
''
