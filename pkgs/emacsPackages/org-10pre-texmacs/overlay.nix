{ }: final_: prev_: {
  org-10pre-texmacs = final_.callPackage (
    { org }:
    let
      compatPackages = final_.overrideScope (_: _: { inherit org; });
    in
    compatPackages.org-texmacs.overrideAttrs (
      finalAttrs: old: {
        patches = (old.patches or [ ]) ++ [ ./org-10pre-compat.patch ];
        passthru = old.passthru // {
          tests = old.passthru.tests // {
            ert-setupfile = compatPackages.callPackage ./tests/ert-setupfile.nix {
              org-texmacs = finalAttrs.finalPackage;
            };
          };
        };
      }
    )
  ) { org = final_.callPackage ./org-source.nix { }; };
}
