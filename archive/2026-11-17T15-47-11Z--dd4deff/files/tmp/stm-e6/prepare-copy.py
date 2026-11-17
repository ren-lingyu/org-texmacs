from pathlib import Path
root = Path.cwd()
source = (root / "lisp/org-texmacs-document.el").read_text()
old = "(unless (and (stringp node)\n                         (memq context '(paragraph footnote)))"
assert source.count(old) == 1
Path(__file__).with_name("org-texmacs-document.el").write_text(source.replace(old, "(unless (stringp node)"))
