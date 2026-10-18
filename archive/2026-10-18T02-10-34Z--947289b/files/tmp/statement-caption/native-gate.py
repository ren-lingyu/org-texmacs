"""Independent native gate; no org-texmacs exporter/worker is loaded."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import xml.etree.ElementTree as ET

out = Path(sys.argv[1])
spec = importlib.util.spec_from_file_location("pdf_links", sys.argv[2])
inspector = importlib.util.module_from_spec(spec)
spec.loader.exec_module(inspector)


def scm(node):
    if isinstance(node, str):
        return json.dumps(node)
    return "(" + node[0] + " " + " ".join(scm(x) for x in node[1:]) + ")"


def run(args, name, env=None):
    result = subprocess.run(["timeout", "60s", *map(str, args)], env=env,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (out / (name + ".stdout")).write_bytes(result.stdout)
    (out / (name + ".stderr")).write_bytes(result.stderr)
    assert result.returncode == 0, (name, result.returncode, result.stderr[-2000:])
    return result.stdout


cases = []
for tag in ("theorem", "remark", "exercise", "proof"):
    for kind in ("ordinary", "math", "opaque-concat", "multiple", "block", "empty", "name-only", "caption-only", "neither"):
        marker = tag.capitalize() + kind.replace("-", "").capitalize()
        cases.append((tag, kind, marker))


def body(variant):
    children = []
    for index, (tag, kind, marker) in enumerate(cases):
        if index:
            children.append(["new-page"])
        has_name = kind not in ("caption-only", "neither")
        has_caption = kind not in ("name-only", "neither")
        prefix = ["concat"]
        if has_name:
            prefix.append(["label", marker])
        if has_caption:
            prefix.append(["dueto", ["concat", marker + " Title ", ["strong", "Bold"]]])
        first = ["concat", marker + " Body ", ["math", "x+y"]] if kind in ("math", "opaque-concat") else ["concat", marker + " Body"]
        if kind == "block":
            first = ["quotation", ["document", marker + " BlockBody"]]
        contents = [] if kind == "empty" else [first]
        if kind == "multiple":
            contents.append(["concat", marker + " SecondParagraph"])
        if len(prefix) > 1:
            if variant == "legacy-name" and kind == "name-only":
                contents.insert(0, prefix[1])
            elif contents and first[0] == "concat":
                contents[0] = (["concat", *prefix[1:], *first[1:]] if variant == "direct"
                               or variant == "legacy-name"
                               else ["surround", prefix, "", first])
            else:
                contents.insert(0, prefix)
        children.append([tag, ["document", *contents]])
        if has_name:
            children.append(["concat", "Reference " + marker + " ", ["reference", marker]])
    return ["document", *children]


def native(style, variant, reload=False):
    name = f"{style}-{variant}" + ("-reload" if reload else "")
    base = out / f"{style}-{variant}"
    tree = body(variant)
    pdf = out / (name + ".pdf")
    readback = out / (name + ".stree")
    render = f'''
      (do ((pass 0 (+ pass 1))) ((= pass 3))
        (do ((i 0 (+ i 1))) ((= i 3)) (update-current-buffer))
        (update-forced) (print-to-file (system->url {scm(str(pdf))})))
      (call-with-output-file {scm(str(readback))}
        (lambda (p) (write (tree->stree (buffer-get-body (current-buffer))) p)))
    '''
    if reload:
        setup = f'(load-buffer (system->url {scm(str(base)+".tm")}))'
        finish = ""
    else:
        setup = f'''(let ((b (buffer-new))) (view-new b) (with-buffer b
          (set-style-list (list {scm(style)}))
          (buffer-set-body b (stree->tree '{scm(tree)}))
          (if (not (equal? '{scm(tree)} (tree->stree (buffer-get-body b))))
            (error "Native readback changed input"))
          (call-with-output-file {scm(str(base)+".tm")}
            (lambda (p) (display (serialize-texmacs (stree->tree
              '(document (TeXmacs "2.1.5") (style (tuple {scm(style)}))
                (body {scm(tree)})))) p)))'''
        finish = "))"
    script = out / (name + ".scm")
    script.write_text('''(use-modules (utils library cursor) (generic document-edit) (generic document-style))
      (begin (catch #t (lambda () ''' + setup + render + finish + '''
        (display "STATEMENT-NATIVE-OK\\n"))
        (lambda args (display "STATEMENT-NATIVE-ERROR ") (write args))) (quit-TeXmacs))
    ''')
    env = os.environ.copy()
    env["TEXMACS_HOME_PATH"] = str(Path(os.environ["TMPDIR"]) / (name + "-config"))
    log = run([env["TEXMACS_PROGRAM"], "-H", "-s", "-x", f"(load {scm(str(script))})"], name, env)
    assert b"STATEMENT-NATIVE-OK" in log, (name, log[-4000:])
    analysis = inspector.inspect(str(pdf))
    (out / (name + "-links.json")).write_text(json.dumps(analysis, indent=2))
    xml = run(["pdftohtml", "-xml", "-i", "-hidden", "-stdout", pdf], name + "-xml")
    (out / (name + ".xml")).write_bytes(xml)
    root = ET.fromstring(xml)
    analysis["fonts"] = [[dict(f.attrib) for f in page.findall("fontspec")] for page in root.findall("page")]
    analysis["text_fonts"] = [[t.attrib.get("font") for t in page.findall("text")]
                              for page in root.findall("page")]
    # The target must land on the same page and statement title/body line,
    # rather than merely having a non-dangling annotation.
    for _, kind, marker in cases:
        if kind in ("caption-only", "neither"):
            continue
        targets = [t for t in analysis["texts"] if marker in t["text"] and "Reference" not in t["text"]]
        assert targets, (name, marker, "statement text missing")
        matching = [l for l in analysis["links"] if l["target"] and any(
            t["page"] == l["target"]["page"] and
            t["rect"][1]-12 <= l["target"]["y"] <= t["rect"][3]+12 for t in targets)]
        if not matching:
            if variant != "legacy-name":
                raise AssertionError((name, marker, "no statement destination"))
            analysis.setdefault("legacy_destination_failures", []).append(marker)
    print("Native complete:", name, flush=True)
    return analysis


def compare(a, b, context):
    assert a["fonts"] == b["fonts"], (context, "font specifications differ")
    assert a["text_fonts"] == b["text_fonts"], (context, "inline fonts differ")
    assert len(a["texts"]) == len(b["texts"]), (context, "text box count differs")
    for x, y in zip(a["texts"], b["texts"]):
        assert (x["text"], x["page"]) == (y["text"], y["page"]), (context, "text/counters differ", x, y)
        assert max(abs(p-q) for p, q in zip(x["rect"], y["rect"])) <= 1, (context, "text layout differs", x, y)
    assert len(a["links"]) == len(b["links"]), (context, "link count differs")
    for x, y in zip(a["links"], b["links"]):
        assert x["page"] == y["page"] and bool(x["target"]) == bool(y["target"]), (context, "link structure differs")
        assert max(abs(p-q) for p, q in zip(x["rect"], y["rect"])) <= 1, (context, "link source differs")
        if x["target"]:
            assert x["target"]["page"] == y["target"]["page"], (context, "destination page differs")
            assert max(abs(x["target"][k]-y["target"][k]) for k in ("x", "y")) <= 1, (context, "destination position differs")


results = {}
for style in ("generic", "article"):
    for variant in ("direct", "surround", "legacy-name"):
        live = native(style, variant)
        reloaded = native(style, variant, True)
        compare(live, reloaded, f"{style}-{variant}: saved reload")
        results[style, variant] = live
    compare(results[style, "direct"], results[style, "surround"], style + ": direct vs surround")
    try:
        compare(results[style, "legacy-name"], results[style, "surround"], style + ": previous NAME-only placement")
    except AssertionError as error:
        (out / (style + "-legacy-difference.txt")).write_text(repr(error.args) + "\n")
    (out / (style + "-legacy-destinations.json")).write_text(json.dumps(
        results[style, "legacy-name"].get("legacy_destination_failures", [])))
(out / "RESULT.txt").write_text("PASS: native direct/surround and saved reload agree within 1pt; generic/article, 36 cases each.\n")
print("STATEMENT-CAPTION-NATIVE-GATE-PASS", flush=True)
