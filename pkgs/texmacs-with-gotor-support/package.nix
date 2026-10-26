{
  lib,
  texmacs,
  callPackage,
}:
let
  sourceGuard = callPackage ./source-guard.nix { };
  gotorPatch = ./local-pdf-gotor.patch;
in
assert lib.assertMsg (
  texmacs.version == "2.1.5"
) "texmacs-with-gotor-support requires a reviewed TeXmacs 2.1.5 renderer";
texmacs.overrideAttrs (old: {
  pname = "texmacs-with-gotor-support";

  # Run after upstream patches/postPatch; unrelated renderer changes are allowed.
  postPatch = (old.postPatch or "") + ''
    renderer=src/Plugins/Pdf/pdf_hummus_renderer.cpp
    ${sourceGuard} "$renderer"
    patch --batch --forward --fuzz=0 -p1 < ${gotorPatch}
  '';

  passthru = (old.passthru or { }) // {
    # The maintained regression exercises the exact build guard and patch.
    gotorSourceGuard = sourceGuard;
    inherit gotorPatch;
  };

  meta = old.meta // {
    description = "TeXmacs with native local PDF GoToR links";
  };
})
