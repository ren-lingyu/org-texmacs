{ pkgs }:
pkgs.runCommand "statement-caption-native-gate" {
  nativeBuildInputs = [ pkgs.texmacs pkgs.poppler-utils
    (pkgs.python3.withPackages (p: [ p.pypdf ])) ];
  TEXMACS_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
} ''
  mkdir -p "$TMPDIR/home" "$out"
  export HOME="$TMPDIR/home"
  export XDG_CONFIG_HOME="$HOME/config"
  export XDG_CACHE_HOME="$HOME/cache"
  python ${./native-gate.py} "$out" ${./tests/ert/pdf-links.py}
''
