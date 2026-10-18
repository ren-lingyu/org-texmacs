"""Compare packaged-font override without host fonts or font registration."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

out = Path(sys.argv[1])
export = sys.argv[2]


def run(args, name, env, seconds=60):
    result = subprocess.run(["timeout", f"{seconds}s", *map(str, args)], env=env,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (out / (name + ".stdout")).write_bytes(result.stdout)
    (out / (name + ".stderr")).write_bytes(result.stderr)
    if result.returncode:
        raise RuntimeError((name, result.returncode, result.stderr[-2000:]))
    return result.stdout


def scheme(node):
    if isinstance(node, str):
        return json.dumps("".join(f"<#{ord(c):X}>" if ord(c) > 127 else c for c in node))
    return "(" + node[0] + " " + " ".join(scheme(x) for x in node[1:]) + ")"


body = ["document", ["section", "标题中文"],
        ["concat", "Body 中文测试 ABC xyz 123. "],
        ["concat", "Repeat 中文测试 ABC xyz 123. "],
        ["concat", "Strong ", ["strong", "中文测试"], " End. "],
        ["concat", "Italic ", ["em", "中文测试"], " End. "],
        ["concat", "Inline ", ["math", "中文"], " End. "],
        ["quotation", ["document", ["concat", "Quote 中文测试. "]]]]


def normal(row):
    pages = []
    for page in row["pages"]:
        fonts = {f["id"]: {k: re.sub(r"^[A-Z]{6}\+", "", v) if k == "family" else v
                           for k, v in f.items() if k != "id"} for f in page["fonts"]}
        pages.append([{**{k: v for k, v in run.items() if k != "font"},
                       "font": fonts[run["font"]]} for run in page["runs"]])
    return pages


rows = {}
comparisons = {}
for package in ("plain", "override"):
    program = os.environ["PROBE_" + package.upper() + "_PROGRAM"]
    for style in ("generic", "article"):
        for mode in ("default", "chinese"):
            name = f"{package}-{style}-{mode}"
            print("Running", name, flush=True)
            env = os.environ.copy()
            env.update(TEXMACS_PROGRAM=program, PROBE_OUT=str(out), PROBE_STYLE=style,
                       PROBE_NAME=name, PROBE_MODE=mode, PROBE_FONT="")
            env["TEXMACS_HOME_PATH"] = str(Path(os.environ["TMPDIR"]) / (name + "-org-config"))
            run([env["EMACS_PROGRAM"], "-Q", "--batch", "--load", export], name + "-export", env)
            for origin in ("native", "reload"):
                key = name + "-" + origin
                env["TEXMACS_HOME_PATH"] = str(Path(os.environ["TMPDIR"]) / (key + "-config"))
                if origin == "reload":
                    setup = f'(load-buffer (system->url {json.dumps(str(out / (name + ".tm")))}))'
                    end = ""
                else:
                    initial = '(init-env-tree "language" (stree->tree "chinese"))' if mode == "chinese" else ""
                    setup = f'''(let ((b (buffer-new))) (view-new b) (with-buffer b
                      (set-style-list (list "{style}")) {initial}
                      (buffer-set-body b (stree->tree '{scheme(body)}))
                      (if (not (equal? '{scheme(body)} (tree->stree (buffer-get-body b))))
                        (error "Native body changed"))'''
                    end = "))"
                pdf = out / (key + ".pdf")
                state = out / (key + "-state.sexp")
                script = out / (key + ".scm")
                script.write_text('''(use-modules (utils library cursor) (generic document-edit) (generic document-style))
                  (begin (catch #t (lambda () ''' + setup + f'''
                    (do ((pass 0 (+ pass 1))) ((= pass 2))
                      (do ((i 0 (+ i 1))) ((= i 3)) (update-current-buffer))
                      (update-forced) (print-to-file (system->url {json.dumps(str(pdf))})))
                    (call-with-output-file {json.dumps(str(state))}
                      (lambda (p) (write (list
                        (tree->stree (buffer-get-body (current-buffer)))
                        (map (lambda (k) (list k (tree->stree (get-env-tree k))))
                             '("font" "language" "font-family" "font-base-size" "math-font"))
                        (getenv "TEXMACS_PATH") (getenv "TEXMACS_FONT_PATH")
                        (if (defined? 'font-database-families) (font-database-families) "unavailable")) p)))
                    {end} (display "OVERRIDE-NATIVE-OK\\n"))
                    (lambda args (display "OVERRIDE-NATIVE-ERROR ") (write args))) (quit-TeXmacs))
                ''')
                log = run([program, "-H", "-s", "-x", f"(load {json.dumps(str(script))})"], key, env)
                assert b"OVERRIDE-NATIVE-OK" in log, (key, log[-2000:])
            for origin in ("org", "native", "reload"):
                key = name + "-" + origin
                pdf = out / (key + ".pdf")
                text = run(["pdftotext", "-layout", pdf, "-"], key + "-text", env).decode()
                fonts = run(["pdffonts", pdf], key + "-fonts", env).decode()
                xml = run(["pdftohtml", "-xml", "-i", "-hidden", "-stdout", pdf], key + "-xml", env)
                pages = [{"page": dict(page.attrib),
                          "fonts": [dict(f.attrib) for f in page.findall("fontspec")],
                          "runs": [{**t.attrib, "text": "".join(t.itertext())}
                                   for t in page.findall("text")]}
                         for page in ET.fromstring(xml).findall("page")]
                rows[key] = {"program": program, "package": package, "style": style,
                             "mode": mode, "origin": origin, "text": text,
                             "pdf_fonts": fonts, "pages": pages,
                             "has_chinese": "中文测试" in text, "literal_fallback": "<#" in text,
                             "sha256": hashlib.sha256(pdf.read_bytes()).hexdigest()}
                if package == "override" and origin == "org":
                    run(["pdftoppm", "-f", "1", "-singlefile", "-scale-to", "1600", "-png",
                         pdf, out / (key + "-page1")], key + "-raster", env)
            a, b, c = (rows[name + "-" + origin] for origin in ("org", "native", "reload"))
            comparisons[name] = {"text_same": a["text"] == b["text"] == c["text"],
                                 "font_layout_same": normal(a) == normal(b) == normal(c),
                                 "has_chinese": a["has_chinese"], "fallback": a["literal_fallback"]}
            print(name, comparisons[name], flush=True)
(out / "summary.json").write_text(json.dumps(rows, ensure_ascii=False, indent=2) + "\n")
(out / "comparison.json").write_text(json.dumps(comparisons, indent=2) + "\n")
print("FONT-OVERRIDE-PROBE-COMPLETE", len(rows), flush=True)
