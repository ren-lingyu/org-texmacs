{ pkgs, emacs }:
pkgs.runCommand "org-texmacs-private-footnote-integration" {
  nativeBuildInputs = [ emacs pkgs.texmacs pkgs.poppler-utils pkgs.ghostscript
    (pkgs.python3.withPackages (p: [ p.pypdf ])) ];
  TEXMACS_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
  EMACS_PROGRAM = pkgs.lib.getExe' emacs "emacs";
} ''
  mkdir -p "$TMPDIR/home" "$out"
  export HOME="$TMPDIR/home"
  export XDG_CONFIG_HOME="$TMPDIR/home/config"
  export XDG_CACHE_HOME="$TMPDIR/home/cache"
  export PROBE_OUT="$out"
  export PROBE_CONTROL="$TMPDIR/control"
  export PROBE_EVENTS="$out/worker-events.sexp"
  export TEXMACS_HOME_PATH="$TMPDIR/texmacs-config"
  python ${./integration.py} "$out" ${./integration.el}
''
