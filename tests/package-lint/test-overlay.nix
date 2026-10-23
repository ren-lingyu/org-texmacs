{ }: final_: prev_: {
  package-lint = final_.callPackage ./test.nix { package-lint = final_.emacsPackages.package-lint; };
}
