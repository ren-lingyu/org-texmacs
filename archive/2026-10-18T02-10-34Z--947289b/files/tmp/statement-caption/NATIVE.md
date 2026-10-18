# Statement caption native gate and implementation

Independent native inputs: no org-texmacs exporter or worker loaded. Locked
TeXmacs 2.1.5, x86_64-linux, generic/article.36cases per style: four statement
tags (theorem/remark/exercise/proof), nine body/metadata combinations (ordinary,
math, opaque concat, multiple paragraphs, first quotation block, empty,
NAME-only, CAPTION-only, neither). Candidate is surround prefix around original
first concat; non-concat/empty has a separate prefix concat. Native roundtrip
checks input tree before rendering; native serialize-texmacs creates .tm for an
independent process to reload. Three print/layout passes resolve native refs.

Initial independent check succeeded at
/nix/store/0br01qfbxn1pd5ramrhrhqfdnamy18vf-statement-caption-native-gate.
Supplementary check adds per-text font assignment and legacy NAME-only structure:
/nix/store/zi530k88bik9lk9gsk5b3l1pix6p3rfc-statement-caption-native-gate.
Direct and surround agree in every text/counter/page, fonts and per-run font IDs,
text/link source geometry and actual destination page/coordinates within1pt;
each variant agrees with its saved-tm reload. Actual printed title and body
content separately verified for all36cases/style from final inspector JSON.

Legacy NAME-only comparison intentionally records differences without weakening
the strict direct/surround or reload gates. Legacy document(label,concat...) puts
body in a separate paragraph; new prefix places it immediately after native
statement title. Normalized text/counters and all actual destination coordinates
are exactly unchanged. Initial supplemental assertion wrongly required legacy
target to land on body line containing marker, overlooking native title line;
that failing assertion does not establish broken legacy references. Raw legacy
layout differences are retained, not reported as layout equivalence.

Pypdf reports duplicate destination-dictionary keys in both candidate variants.
Targets still resolve and actual page/position checks pass. No claim of arbitrary
styles/platforms, GUI, PostScript, float-caption footnote layout, or global native
PDF cleanup. No TeXmacs style mutation or worker protocol change.

