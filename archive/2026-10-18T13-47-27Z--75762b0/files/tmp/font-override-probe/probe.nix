{ pkgs, emacs }:
let
  overridden = pkgs.texmacs.override {
    extraFonts = true;
    chineseFonts = true;
    japaneseFonts = true;
    koreanFonts = true;
  };
in pkgs.runCommand "org-texmacs-font-override-probe" {
  nativeBuildInputs = [ emacs pkgs.texmacs overridden pkgs.poppler-utils
    (pkgs.python3.withPackages (p: [ p.pypdf ])) ];
  EMACS_PROGRAM = pkgs.lib.getExe' emacs "emacs";
  PROBE_PLAIN_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
  PROBE_OVERRIDE_PROGRAM = pkgs.lib.getExe' overridden "texmacs";
  FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = []; };
} ''
  mkdir -p "$TMPDIR/home" "$out"
  export HOME="$TMPDIR/home"
  export XDG_CONFIG_HOME="$HOME/config"
  export XDG_CACHE_HOME="$HOME/cache"
  python ${./probe.py} "$out" ${./export.el}
''
