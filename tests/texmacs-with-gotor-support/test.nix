{
  lib,
  runCommand,
  coreutils,
  gnutar,
  gzip,
  patch,
  python3,
  makeFontsConf,
  texmacs,
  texmacsWithGotorSupport,
}:
runCommand "texmacs-gotor-regression"
  {
    nativeBuildInputs = [
      coreutils
      gnutar
      gzip
      patch
      (python3.withPackages (ps: [
        ps.pypdf
        ps.pymupdf
      ]))
    ];
    BASELINE_TEXMACS = lib.getExe' texmacs "texmacs";
    CANDIDATE_TEXMACS = lib.getExe' texmacsWithGotorSupport "texmacs";
    SOURCE_GUARD = texmacsWithGotorSupport.gotorSourceGuard;
    GOTOR_PATCH = texmacsWithGotorSupport.gotorPatch;
    FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ ]; };
  }
  ''
    export HOME="$TMPDIR/home"
    export XDG_CONFIG_HOME="$HOME/config" XDG_CACHE_HOME="$HOME/cache"
    export XDG_DATA_HOME="$HOME/data" XDG_RUNTIME_DIR="$HOME/runtime"
    export LC_ALL=C.UTF-8 TZ=UTC
    unset DISPLAY WAYLAND_DISPLAY DBUS_SESSION_BUS_ADDRESS TEXMACS_FONT_PATH
    mkdir -p "$HOME" "$XDG_RUNTIME_DIR" source "$out"
    tar -xf ${texmacs.src} --strip-components=1 -C source --wildcards \
      '*/src/Plugins/Pdf/pdf_hummus_renderer.cpp'
    timeout --kill-after=10s 300s python ${./test.py} "$PWD/source" "$PWD/runtime" "$out"
  ''
