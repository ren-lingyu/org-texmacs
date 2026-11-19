{ extraArgs }: final_: prev_: {
  org-texmacs = final_.callPackage (
    {
      lib,
      mkChecks,
      melpaBuild,
      emacsWithPackages,
      citeproc,
      package-lint,
      runCommand,
      coreutils,
      gnutar,
      patch,
      poppler-utils,
      python3,
      org,
      org-roam,
      texmacs,
    }@args:
    assert lib.assertMsg (lib.versionAtLeast org.version "9.8.10") "org-texmacs requires Org >= 9.8.10";
    (import extraArgs.source args).overrideAttrs {
      postPatch = builtins.concatStringsSep " " [
        "substituteInPlace org-texmacs-core.el"
        "--replace-fail"
        "'(defcustom org-texmacs-program \"texmacs\"'"
        "'(defcustom org-texmacs-program \"${lib.getExe' texmacs "texmacs"}\"'"
      ];
    }
  ) { inherit (extraArgs) mkChecks; };
}
