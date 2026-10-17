{ pkgs, emacs } : (

  pkgs.runCommand "org-texmacs-ert" {
    nativeBuildInputs = [
      emacs
      pkgs.guile
      pkgs.texmacs
      pkgs.poppler-utils
      (pkgs.python3.withPackages (pythonPackages: [ pythonPackages.pypdf ]))
    ];
  } (pkgs.replaceVarsWith {
    src = ./run.scm;
    isExecutable = true;
    replacements = {
      guile = pkgs.lib.getExe pkgs.guile;
      emacs = pkgs.lib.getExe' emacs "emacs";
      testFile = "${./ert.el}";
      readmeFile = "${../../README.org}";
      pdfLinksFile = "${./pdf-links.py}";
      texmacs = pkgs.lib.getExe' pkgs.texmacs "texmacs";
    };
  })

)
