{ pkgs, emacs, extensionSources }:

# The caller supplies an Emacs with org-texmacs and Org-roam, and explicit,
# pinned Elisp-only source directories for the three real extensions.
pkgs.runCommand "org-texmacs-org-extension-integration" {
  nativeBuildInputs = [ emacs pkgs.texmacs pkgs.poppler-utils ];
  ORG_TEXMACS_TEST_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
  ORG_TEXMACS_TEST_README = ../../README.org;
} ''
  mkdir -p "$TMPDIR/home" "$out"
  export HOME="$TMPDIR/home"
  set +e
  emacs -Q --batch \
    -L ${extensionSources.include} \
    -L ${extensionSources.organize} \
    -L ${extensionSources.blog} \
    --load ${../ert/ert.el} --load ${./phase4.el} \
    --eval '(ert-run-tests-batch-and-exit "^org-texmacs-integration-")' > "$out/ert.log" 2>&1
  status=$?
  set -e
  cat "$out/ert.log"
  exit "$status"
''
