{
  lib,
  org10pre,
  mkChecks,
  melpaBuild,
  emacsWithPackages,
  citeproc,
  package-lint,
  org,
  runCommand,
  coreutils,
}:
melpaBuild (finalAttrs_: {
  src = lib.fileset.toSource {
    root = ./src;
    fileset = ./src;
  };

  pname = "org-texmacs";
  version = "0.8.0";
  melpaVersion = finalAttrs_.version;

  patches = lib.optionals org10pre [ ./org10pre/patches/org-10pre-compat.patch ];

  files = ''(:defaults "org-texmacs-worker.scm")'';
  packageRequires = [ org ];
  turnCompilationWarningToError = true;

  doCheck = true;
  checkInputs = [ package-lint ];
  checkPhase = ''
    runHook preCheck

    (
      export HOME="$TMPDIR/package-lint-home"
      export ORG_TEXMACS_TEST_SOURCE="${finalAttrs_.src}"
      mkdir -p "$HOME"

      ${lib.getExe' coreutils "timeout"} --kill-after=10s 120s emacs -Q --batch \
        --funcall package-activate-all \
        --load ${./package-lint.el}
    )

    runHook postCheck
  '';

  passthru.tests = import ./tests {
    setupfileTest = if org10pre then ./org10pre/tests/setupfile.el else null;
    inherit
      lib
      mkChecks
      runCommand
      coreutils
      ;
    emacsPackages = {
      inherit emacsWithPackages citeproc org;
      org-texmacs = finalAttrs_.finalPackage;
    };
  };

  meta = {
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
  };
})
