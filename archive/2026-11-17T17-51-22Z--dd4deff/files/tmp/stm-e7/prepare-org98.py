"""Prepare fixed Org source for batch probes; invoke from project root."""
from pathlib import Path
import sys

source = Path(sys.argv[1]) / "lisp"
target = Path(__file__).parent / "org98"
target.mkdir(exist_ok=True)
for item in source.glob("*.el"):
    (target / item.name).write_bytes(item.read_bytes())
(target / "org-version.el").write_text(
    ';;; -*- lexical-binding: t; -*-\n'
    '(defun org-release () "9.8")\n'
    '(defun org-git-version () "9.8-89df5bf")\n'
    "(provide 'org-version)\n"
)
