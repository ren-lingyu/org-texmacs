{
  src,
  emacs,
  pkgs,
  llib,
}:
llib.tests.mkChecks {
  root = ./.;
  overlayFile = "test-overlay.nix";
  separator = "-";

  # Only directories with a test overlay enter the default checks. Integration
  # remains a separate entry requiring caller-supplied extension sources.
  args = {
    inherit (pkgs)
      lib
      runCommand
      coreutils
      gnutar
      patch
      texmacs
      poppler-utils
      python3
      emacsPackages
      ;
    inherit emacs src;
    testSupport = import ./support;
  };
}
