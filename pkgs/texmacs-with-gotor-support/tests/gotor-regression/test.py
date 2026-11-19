"""Native renderer regression, independent of org-texmacs and font wrappers."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
from urllib.parse import unquote

import pymupdf
from pypdf import PdfReader, PdfWriter


def check_source_guard(source, output):
    renderer = source / "src/Plugins/Pdf/pdf_hummus_renderer.cpp"
    original = renderer.read_text()

    def guard(accepted):
        result = subprocess.run(
            [os.environ["SOURCE_GUARD"], str(renderer)],
            capture_output=True,
            text=True,
            check=False,
        )
        if (result.returncode == 0) != accepted:
            raise AssertionError(result.stderr or "Source guard accepted unexpected input")

    guard(True)
    renderer.write_text("// Unrelated renderer comment.\n" + original)
    guard(True)
    # A zero-fuzz patch may relocate after unrelated changes.
    patched = subprocess.run(
        ["patch", "--batch", "--forward", "--fuzz=0", "-p1", "-i", os.environ["GOTOR_PATCH"]],
        cwd=source,
        capture_output=True,
        text=True,
        check=True,
    )
    (output / "patch.log").write_text(patched.stdout + patched.stderr)
    guard(False)  # Reject accidental double application.
    changed = original.replace("/S /URI /URI (", "/S /Launch /F (")
    assert changed != original
    renderer.write_text(changed)
    guard(False)
    renderer.write_text(original.replace("pdf_hummus_renderer_rep::href (", "renamed::href ("))
    guard(False)
    renderer.write_text(original)
    print(
        "Source guard: unrelated change accepted, changed dispatch/missing function/double patch rejected",
        flush=True,
    )


def inspect(path):
    actions = []
    for page in PdfReader(path).pages:
        for reference in page.get("/Annots", []):
            annotation = reference.get_object()
            action = annotation.get("/A")
            action = action.get_object() if action is not None else {}
            kind = str(action.get("/S", "internal"))
            if kind == "/GoToR":
                spec = action["/F"].get_object()
                assert spec["/Type"] == "/Filespec"
                assert list(action["/D"]) == [0, "/Fit"]
                actions.append({"kind": kind, "file": str(spec["/UF"])})
            elif kind == "/URI":
                actions.append({"kind": kind, "uri": str(action["/URI"])})
            else:
                assert "/Dest" in annotation, annotation
                actions.append({"kind": kind, "destination": str(annotation["/Dest"])})
    with pymupdf.open(path) as document:
        files = sorted(
            os.path.normpath(unquote(link["file"]))
            for page in document
            for link in page.get_links()
            if link["kind"] == pymupdf.LINK_GOTOR and link["page"] == 0
        )
        text = "".join(page.get_text() for page in document)
    return {"actions": actions, "reader_files": files, "text": text}


def render(root, output, mode, executable):
    tree = root / mode
    docs = tree / "docs"
    docs.mkdir(parents=True)
    files = [
        "article.pdf",
        "./article.pdf",
        "../parent.pdf",
        "sub/nested.pdf",
        "space name.pdf",
        "子/é.pdf",
        "paren(name).pdf",
        "UPPER.PDF",
        str(docs / "absolute.pdf"),
    ]
    controls = [
        "https://example.org/article.pdf",
        "mailto:test@example.org",
        "article.tm",
        "article.pdf#there",
        "article.pdf?download=1",
        "//server/article.pdf",
        "file:article.pdf",
    ]
    for filename in files:
        target = docs / filename
        target.parent.mkdir(parents=True, exist_ok=True)
        writer = PdfWriter()
        writer.add_blank_page(width=100, height=100)
        writer.write(target)
    quote = lambda value: json.dumps(str(value), ensure_ascii=False)
    nodes = ['"Renderer regression"', '(label "inside")']
    nodes += [
        f'(concat (hlink "File {i}" ,(lit {quote(name)})) " ")' for i, name in enumerate(files)
    ]
    nodes += [
        f'(concat (hlink "Control {i}" ,(lit {quote(name)})) " ")'
        for i, name in enumerate(controls)
    ]
    nodes += ['(hlink "Internal" "#inside")']
    script = tree / "render.scm"
    script.write_text(
        "(use-modules (utils library cursor) (generic document-edit))\n"
        "(define (lit s) (utf8->cork s))\n"
        "(let ((buffer (buffer-new))) (view-new buffer) (with-buffer buffer\n"
        '  (set-style-list \'("generic"))\n'
        "  (buffer-set-body buffer (stree->tree `(document " + " ".join(nodes) + ")))\n"
        "  (do ((pass 0 (+ pass 1))) ((= pass 2))\n"
        "    (do ((i 0 (+ i 1))) ((= i 3)) (update-current-buffer))\n"
        "    (update-forced) (print-to-file (system->url " + quote(docs / "index.pdf") + ")))))\n"
        '(display "GOTOR-REGRESSION-OK\\n")\n(quit-TeXmacs)\n'
    )
    home = tree / "home"
    home.mkdir()
    env = dict(
        os.environ,
        HOME=str(home),
        TEXMACS_HOME_PATH=str(home / "texmacs"),
        XDG_CONFIG_HOME=str(home / "config"),
        XDG_CACHE_HOME=str(home / "cache"),
        XDG_DATA_HOME=str(home / "data"),
        XDG_RUNTIME_DIR=str(home / "runtime"),
    )
    (home / "runtime").mkdir()
    print("Rendering " + mode, flush=True)
    completed = subprocess.run(
        [executable, "-H", "-s", "-x", "(load " + quote(script) + ")"],
        cwd=docs,
        env=env,
        capture_output=True,
        timeout=120,
    )
    (output / (mode + ".stdout")).write_bytes(completed.stdout)
    (output / (mode + ".stderr")).write_bytes(completed.stderr)
    if completed.returncode or b"GOTOR-REGRESSION-OK" not in completed.stdout:
        raise AssertionError(
            completed.stdout.decode(errors="replace") + completed.stderr.decode(errors="replace")
        )
    report = inspect(docs / "index.pdf")
    actions = report["actions"]
    observed = {a["uri"] for a in actions if a["kind"] == "/URI"}
    internal = [a for a in actions if a["kind"] == "internal"]
    assert internal and len({a["destination"] for a in internal}) == 1, internal
    gotor = [a for a in actions if a["kind"] == "/GoToR"]
    if mode == "baseline":
        assert observed == set(files + controls), observed
        assert not gotor and not report["reader_files"]
    else:
        assert observed == set(controls), observed
        assert {a["file"] for a in gotor} == set(files), gotor
        assert set(report["reader_files"]) == {os.path.normpath(name) for name in files}
        moved = root / "relocated"
        shutil.copytree(tree, moved)
        assert inspect(moved / "docs/index.pdf") == report
        for name in files:
            if not Path(name).is_absolute():
                assert (moved / "docs" / name).is_file(), name
    shutil.copytree(docs, output / mode)
    print(mode + ": PDF actions, destinations and reader interpretation passed", flush=True)
    return report


source, root, output = map(Path, sys.argv[1:])
check_source_guard(source, output)
root.mkdir()
baseline = render(root, output, "baseline", os.environ["BASELINE_TEXMACS"])
candidate = render(root, output, "candidate", os.environ["CANDIDATE_TEXMACS"])
assert baseline["text"] == candidate["text"]
assert len(baseline["actions"]) == len(candidate["actions"])
assert [a for a in baseline["actions"] if a["kind"] == "internal"] == [
    a for a in candidate["actions"] if a["kind"] == "internal"
]
(output / "results.json").write_text(
    json.dumps({"baseline": baseline, "candidate": candidate}, ensure_ascii=False, indent=2)
)
print("GoToR regression passed without font wrappers or org-texmacs", flush=True)
