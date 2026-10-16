# User-created native footnote reproduction

User reports using TeXmacs from nix develop, directly creating a new file and
inserting a footnote, then exporting PDF. First forward reference reports
"destinition not found". Agent did not launch or observe GUI. User asks to
postpone the unrelated manual.org bibliography configuration issue.

Artifacts supplied by user: tmp/realworld_test/test_footnote.{tm,pdf}.
The329byte .tm format header says TeXmacs2.1.5, generic style, paper medium;
body is only Test the Footnote + native footnote(Test), no package surround.
Saved references contain footnote-1 and footnr-1, each tuple(1,1).
PDF8436bytes, PDF1.4. Read-only extraction of its uncompressed indirect
annotation/destination/catalog dictionaries shows first forward /label0 missing
from catalog destination dictionary; backlink /label1 exists. This is artifact
evidence, not only a viewer report. Numeric IDs do not expose original native
key spelling; exact runtime anchor registration still uninstrumented.

Source references exist, so a bibliography/source acquisition issue is unrelated.
Native interactive creation/export as reported reproduces without package worker
or its headless buffer lifecycle. Exact native binding/PDF destination defect
and other native versions remain unestablished; no project workaround selected.
User-paired file provenance is reported, not independently witnessed production.
No tests/builds or project mutations performed in this inspection.

SHA-256 / bytes:
- tmp/realworld_test/test_footnote.tm: 9292549cfdf671067de2d8b6a7d8c87c2788985215f5d54c4ccc1b82ce02b339 / 329
- tmp/realworld_test/test_footnote.pdf: f68a3add30bc20e465673a881c630f6478fa44ed4e2ade1884e3186857b31bf5 / 8436

PDF dictionary extracts (original ASCII content; surrounding object headers labelled):

```text
object 11
<<
		/label1 [ 9 0 R /XYZ 162.96 754.8 null ]
		/label2 [ 9 0 R /XYZ 162.96 757.92 null ]
		/label3 [ 9 0 R /XYZ 85.02 733.68 null ]
>>

object 8
<<
	/Type /Annot
	/Subtype /Link
	/Border [16 16 0 [3 10]] /Color [0.75 0.5 1.0]
	/Rect [84.72 726.72 89.58 733.08]
	/Dest /label1
>>

object 7
<<
	/Type /Annot
	/Subtype /Link
	/Border [16 16 0 [3 10]] /Color [0.75 0.5 1.0]
	/Rect [162.66 751.62 167.22 757.32]
	/Dest /label0
>>

object 24
<<
	/Type /Catalog
	/Pages 10 0 R
	/Dests 11 0 R
>>
```
