{ pkgs, emacs }:
pkgs.runCommand "org-texmacs-footnote-anchor-probe" {
  nativeBuildInputs = [ emacs pkgs.texmacs pkgs.poppler-utils pkgs.ghostscript
    (pkgs.python3.withPackages (p: [ p.pypdf ])) ];
  TEXMACS_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
  EMACS_PROGRAM = pkgs.lib.getExe' emacs "emacs";
} ''
  mkdir -p "$TMPDIR/home" "$out"
  export HOME="$TMPDIR/home"
  export XDG_CONFIG_HOME="$TMPDIR/home/config"
  export XDG_CACHE_HOME="$TMPDIR/home/cache"
  python ${./anchor-probe.py} "$out" ${./export.el}
''
