{ pkgs, emacs }:
let
  cjkFonts = [ pkgs.texlive.pkgs.fandol.tex ];
  fontConfig = pkgs.makeFontsConf { fontDirectories = cjkFonts; };
in pkgs.runCommand "org-texmacs-block-font-probe" {
  nativeBuildInputs = [ emacs pkgs.texmacs pkgs.poppler-utils pkgs.fontconfig
    (pkgs.python3.withPackages (p: [ p.pypdf ])) ];
  EMACS_PROGRAM = pkgs.lib.getExe' emacs "emacs";
  TEXMACS_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
  PROBE_FONTCONFIG = fontConfig;
  PROBE_FONT_PATH = pkgs.lib.concatStringsSep ":" (map (p: "${p}") cjkFonts);
} ''
  mkdir -p "$TMPDIR/home" "$out"
  export HOME="$TMPDIR/home"
  export XDG_CONFIG_HOME="$TMPDIR/home/config"
  export XDG_CACHE_HOME="$TMPDIR/home/cache"
  export ORG_TEXMACS_TEST_PROGRAM="$TEXMACS_PROGRAM"
  python ${./probe.py} "$out" ${./export.el} ${./tests/ert/ert.el}
''
