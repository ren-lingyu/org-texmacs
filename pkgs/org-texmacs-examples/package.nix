{
  lib,
  runCommand,
  coreutils,
  emacs,
  poppler-utils,
}:
let
  examples = lib.fileset.toSource {
    root = ./sources;
    fileset = ./sources;
  };

  documents =
    lib.concatMap
      (
        language:
        map
          (document: {
            inherit language document;
            profile = if document == "index" then "generic" else "article";
          })
          [
            "index"
            "article"
          ]
      )
      [
        "en"
        "zh"
      ];

  # Each document has its own Emacs process, native worker and writable state.
  buildDocument =
    {
      language,
      document,
      profile,
    }:
    runCommand "org-texmacs-example-${language}-${document}"
      {
        nativeBuildInputs = [
          coreutils
          poppler-utils
        ];
      }
      ''
        set -o pipefail
        export HOME="$TMPDIR/home"
        export TEXMACS_HOME_PATH="$HOME/texmacs"
        export XDG_CONFIG_HOME="$HOME/config"
        export XDG_CACHE_HOME="$HOME/cache"
        export XDG_DATA_HOME="$HOME/data"
        export XDG_RUNTIME_DIR="$HOME/runtime"
        export TZ=UTC
        export LC_ALL=C.UTF-8
        unset DISPLAY WAYLAND_DISPLAY DBUS_SESSION_BUS_ADDRESS
        mkdir -p "$HOME" "$TEXMACS_HOME_PATH" "$XDG_CONFIG_HOME" \
          "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_RUNTIME_DIR" \
          "$out/pdf" "$out/texmacs" "$out/sources"
        # No host paths, user init files or existing TeXmacs worker are used.
        mkdir source
        cp ${examples}/${language}/*.org source/
        cp -R --no-preserve=mode ${examples}/${language}/chapters source/
        cp ${examples}/shared/configuration.org source/chapters/configuration-source.org
        cp ${examples}/shared/references.org source/chapters/references.org
        cd source
        export ORG_TEXMACS_DOCUMENT_DIRECTORY="$PWD"
        export ORG_TEXMACS_DOCUMENT_SOURCE="$PWD/${document}.org"
        export ORG_TEXMACS_DOCUMENT_OUTPUT="$PWD/${document}"
        export ORG_TEXMACS_DOCUMENT_CONFIG_SOURCE="$PWD/chapters/configuration-source.org"
        export ORG_TEXMACS_DOCUMENT_PROFILE="${profile}"
        export ORG_TEXMACS_DOCUMENT_BIBLIOGRAPHY_SOURCE="$PWD/chapters/references.org"
        export ORG_TEXMACS_DOCUMENT_BIBLIOGRAPHY="$PWD/chapters/references.bib"

        echo "Building ${language}/${document}"
        timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch \
          --load ${./build.el} 2>&1

        echo "Inspecting ${language}/${document} artifacts"
        test -s "${document}.tm"
        test -s "${document}.pdf"
        pdfinfo "${document}.pdf"
        cp "${document}.pdf" "$out/pdf/"
        cp "${document}.tm" "$out/texmacs/"
        # Retain canonical Org sources and derived configuration/bibliography.
        cp *.org "$out/sources/"
        cp -R chapters "$out/sources/"
      '';

  outputs = map (document: document // { output = buildDocument document; }) documents;
in
runCommand "org-texmacs-examples"
  {
    nativeBuildInputs = [ coreutils ];
    meta = {
      description = "English and Chinese org-texmacs examples";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.linux;
    };
  }
  ''
    mkdir -p "$out"
    ${lib.concatMapStringsSep "\n" (document: ''
      mkdir -p "$out/pdf/${document.language}" \
        "$out/texmacs/${document.language}" "$out/sources/${document.language}"
      cp ${document.output}/pdf/${document.document}.pdf "$out/pdf/${document.language}/"
      cp ${document.output}/texmacs/${document.document}.tm "$out/texmacs/${document.language}/"
      cp -R ${document.output}/sources "$out/sources/${document.language}/${document.document}"
    '') outputs}
  ''
