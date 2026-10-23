{ emacs, emacsPackagesFor }: (emacsPackagesFor emacs).withPackages (epkgs_: [ epkgs_.org-texmacs ])
