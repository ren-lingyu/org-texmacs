{ }: final_: prev_: {
  emacs-with-org-texmacs = final_.callPackage ./package.nix { emacs = final_.emacs; };
}
