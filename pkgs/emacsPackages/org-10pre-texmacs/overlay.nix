{ extraArgs }: final_: prev_: {
  org-10pre-texmacs = final_.callPackage (
    { org, texmacs }:
    let
      compatPackages = final_.overrideScope (_: _: { inherit org; });
    in
    compatPackages.callPackage (
      {
        lib,
        mkChecks,
        melpaBuild,
        emacsWithPackages,
        citeproc,
        package-lint,
        runCommand,
        coreutils,
        org,
      }@args:
      assert lib.assertMsg (lib.versionAtLeast org.version "9.8.10") "org-texmacs requires Org >= 9.8.10";
      (import extraArgs.source (args // { org10pre = true; })).overrideAttrs {
        postPatch = builtins.concatStringsSep " " [
          "substituteInPlace org-texmacs-core.el"
          "--replace-fail"
          "'(defcustom org-texmacs-program \"texmacs\"'"
          "'(defcustom org-texmacs-program \"${lib.getExe' texmacs "texmacs"}\"'"
        ];
      }
    ) { inherit (extraArgs) mkChecks; }
  ) { org = final_.callPackage ./org-source.nix { }; };
}
