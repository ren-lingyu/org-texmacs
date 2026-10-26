{ lib, writeShellScript }:
writeShellScript "texmacs-gotor-source-guard" ''
  set -eu
  renderer="$1"
  # Inspect only the reviewed action dispatch in href, not unrelated renderer code.
  expected=$(printf '%s' ${lib.escapeShellArg ''
    if (starts (label, "#")) {
      dict << "\t/Dest /label" << as_string(get_label_id(prepare_text (label))) << "\r\n";
    }
    else {
      dict << "/A << /S /URI /URI (" << prepare_text (label) << ") >>\r\n";
    }
  ''} | sed 's/^[[:space:]]*//')
  href=$(sed -n '/^pdf_hummus_renderer_rep::href (/,/^}/p' "$renderer" | sed 's/^[[:space:]]*//')
  case "$href" in
    *"$expected"*) ;;
    *)
      echo "Unreviewed TeXmacs href action dispatch; review the GoToR patch before building" >&2
      exit 1
      ;;
  esac
  test "$(grep -c '^pdf_hummus_renderer_rep::href (' "$renderer")" = 1
''
