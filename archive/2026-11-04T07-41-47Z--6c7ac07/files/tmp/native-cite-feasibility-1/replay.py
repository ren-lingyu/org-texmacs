"""Reconstruct runtime inputs from the recorded project commit; never writes Git.
Run from project root. Destination must be a new child of its validated tmp/.
N5's four staged documentation/unused-Cite-test changes are intentionally omitted;
the Lisp, worker, lock, support and experiment sources are the tested runtime input.
"""
import argparse
from pathlib import Path
import subprocess
import shutil

parser = argparse.ArgumentParser()
parser.add_argument('--git', required=True)
parser.add_argument('destination')
args = parser.parse_args()
project = Path.cwd().resolve()
tmp = project / 'tmp'
assert tmp.is_dir() and not tmp.is_symlink()
assert subprocess.run([args.git, 'check-ignore', '-q', '--', 'tmp/']).returncode == 0
assert not subprocess.check_output([args.git, 'ls-files', '--', 'tmp/'])
destination = Path(args.destination).resolve()
assert destination.is_relative_to(tmp.resolve()) and not destination.exists()
source = Path(__file__).resolve().parent
head = '6c7ac07ba4f4c936abe99fb15d1915df6e211deb'
files = subprocess.check_output([args.git, 'ls-tree', '-r', '--name-only', head]).decode().splitlines()
destination.mkdir()
for name in files:
    target = destination / name
    assert target.resolve().is_relative_to(destination)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(subprocess.check_output([args.git, 'show', head + ':' + name]))
for name in ['flake.nix', 'experiment.nix', 'probe-common.el', 'styles.scm', 'styles.el',
             'handoff.el', 'adapter.el', 'end-to-end.el', 'styles-unsafe-original.scm']:
    shutil.copyfile(source / name, destination / name)
patch = (source.parent / 'native-cite-feasibility-evidence/document-prefix.patch').read_text()
# This experiment has exactly one insertion hunk; check its complete context.
lines = patch.splitlines(keepends=True)[3:]
before = ''.join(line[1:] for line in lines if line[0] in ' -')
after = ''.join(line[1:] for line in lines if line[0] in ' +')
target = destination / 'lisp/org-texmacs-document.el'
text = target.read_text()
assert text.count(before) == 1
target.write_text(text.replace(before, after))
print(destination)
