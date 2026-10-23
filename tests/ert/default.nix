{
  runCommand,
  ert-core,
  ert-native,
  ert-pdf,
}:

# Dependency-only aggregate: each leaf runs ERT once.
runCommand "org-texmacs-ert" { } ''
  mkdir -p "$out"
  ln -s ${ert-core} "$out/core"
  ln -s ${ert-native} "$out/native"
  ln -s ${ert-pdf} "$out/pdf"
''
