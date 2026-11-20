{
  lib,
  fetchFromGitHub,
  melpaBuild,
  compat,
  gnumake,
  emacs,
}:
let
  revision = "fd6546e1a9dddedd913a4adaf2ea76eea65c7f67";
in
melpaBuild (finalAttrs_: {
  pname = "org";
  version = "10.0-pre";
  melpaVersion = "10.0pre";
  commit = revision;

  src = fetchFromGitHub {
    owner = "bzg";
    repo = "org-mode";
    rev = revision;
    hash = "sha256-NSEY+I7kKPs2EUaA/p2DBtW8SVIrp/f1UP+FkX/BQSE=";
  };

  files = ''(:defaults "etc")'';
  packageRequires = [ compat ];
  nativeBuildInputs = [ gnumake ];
  preBuild = ''
    make autoloads ORGVERSION=${finalAttrs_.version} GITVERSION=${
      builtins.substring 0 8 revision
    } EMACS=${lib.getExe emacs}
  '';

  meta.license = lib.licenses.gpl3Plus;
})
