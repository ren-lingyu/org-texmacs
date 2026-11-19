{
  runCommand,
  coreutils,
  ert-pdf-render,
  ert-pdf-document,
}:
# Dependency-only aggregate: each PDF case runs in exactly one leaf.
runCommand "org-texmacs-ert-pdf" { nativeBuildInputs = [ coreutils ]; } ''
  set -o pipefail
  mkdir -p "$out"
  ln -s ${ert-pdf-render} "$out/render"
  ln -s ${ert-pdf-document} "$out/document"
  cat ${ert-pdf-render}/test-names.txt ${ert-pdf-document}/test-names.txt \
    | sort > "$out/test-names.txt"
  if [ -n "$(uniq -d "$out/test-names.txt")" ]; then
    echo "Duplicate PDF test names across leaves" >&2
    exit 1
  fi
  cat ${ert-pdf-render}/ert.log ${ert-pdf-document}/ert.log > "$out/ert.log"
''
