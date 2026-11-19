{ }: final_: prev_: {
  # The parser patch targets the Org 9.8.10 ELPA source.
  caption-inline-footnotes =
    if final_.lib.getVersion final_.emacsPackages.org == "9.8.10" then
      final_.callPackage ./test.nix { }
    else
      { };
}
