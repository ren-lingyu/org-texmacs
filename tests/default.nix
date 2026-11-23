{
  packages,
  pkgs,
  lib,
  llib,
}:
llib.tests.mkChecks {
  root = ./.;
  overlayFile = "test-overlay.nix";
  separator = "-";

  checks = lib.mapAttrsRecursiveCond (value_: !lib.isDerivation value_) (
    path_: value_: value_.tests or { }
  ) packages;

  args = {
    inherit pkgs;
    testSupport = {
      csl = ./support/csl.el;
      document = ./support/document.el;
      native = ./support/native.el;
      pdf = ./support/pdf.el;
    };
  };
}
