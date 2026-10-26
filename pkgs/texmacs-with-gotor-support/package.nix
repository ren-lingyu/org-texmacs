{ lib, texmacs }:
assert lib.assertMsg (
  texmacs.version == "2.1.5"
) "texmacs-with-gotor-support requires a reviewed TeXmacs 2.1.5 renderer";
texmacs.overrideAttrs (old: {
  pname = "texmacs-with-gotor-support";

  # Run after upstream patches and postPatch, so renderer changes fail closed.
  postPatch = (old.postPatch or "") + ''
    renderer=src/Plugins/Pdf/pdf_hummus_renderer.cpp
    echo "310dc4526ecc7688683a69672f7004bb514bca6d8c4c55fad11540ea45db67ba  $renderer" | sha256sum --check
    patch --fuzz=0 -p1 < ${./local-pdf-gotor.patch}
    echo "ab2ee98e69c20ac3fb744e4771a20d523edb61b6dee338192d5f3e9c22f0cbc0  $renderer" | sha256sum --check
  '';

  meta = old.meta // {
    description = "TeXmacs with native local PDF GoToR links";
  };
})
