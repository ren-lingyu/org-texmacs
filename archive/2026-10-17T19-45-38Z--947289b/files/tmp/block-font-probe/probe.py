"""Isolated block-regression and native CJK-font comparison matrix."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import xml.etree.ElementTree as ET

out = Path(sys.argv[1])
export = sys.argv[2]
ert = sys.argv[3]


def run(args, name, env, seconds=75):
    result = subprocess.run(["timeout", f"{seconds}s", *map(str, args)], env=env,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (out / (name + ".stdout")).write_bytes(result.stdout)
    (out / (name + ".stderr")).write_bytes(result.stderr)
    if result.returncode:
        raise RuntimeError((name, result.returncode,
                            result.stdout[-3000:].decode(errors="replace"),
                            result.stderr[-3000:].decode(errors="replace")))
    return result.stdout


def scheme(value):
    if isinstance(value, str):
        return json.dumps("".join(f"<#{ord(c):X}>" if ord(c) > 127 else c
                                  for c in value), ensure_ascii=True)
    return "(" + value[0] + " " + " ".join(scheme(c) for c in value[1:]) + ")"


body = ["document", ["section", "标题中文"],
        ["concat", "Body 中文测试 ABC xyz 123. "],
        ["concat", "Repeat 中文测试 ABC xyz 123. "],
        ["concat", "Strong ", ["strong", "中文测试"], " End. "],
        ["concat", "Italic ", ["em", "中文测试"], " End. "],
        ["concat", "Inline ", ["math", "中文"], " End. "],
        ["quotation", ["document", ["concat", "Quote 中文测试. "]]]]
base_env = os.environ.copy()
base_env["TEXMACS_HOME_PATH"] = str(Path(os.environ["TMPDIR"]) / "regression-config")
selector = "'(member org-texmacs-document-quote-uniform-quotation org-texmacs-document-quote-and-center-containers org-texmacs-document-list-containers-native org-texmacs-pdf-block-quotation-and-center-layout org-texmacs-document-real-chinese-end-to-end org-texmacs-pdf-preformatted-lines-and-indent org-texmacs-document-preformatted-native-and-provenance org-texmacs-pdf-list-multiparagraph-native-layout org-texmacs-pdf-table-alignment-frontend-and-native-layout org-texmacs-issue13-source-real-islands-and-native-statements org-texmacs-issue13-stage2-native-layout-counter-and-reload org-texmacs-issue13-stage3-native-prevalidation org-texmacs-issue13-stage3-exporter-native-pdf-and-reload org-texmacs-issue13-stage4-native-label-placements)"
run([os.environ["EMACS_PROGRAM"], "-Q", "--batch", "--load", ert, "--eval",
     f"(ert-run-tests-batch-and-exit {selector})"], "existing-regressions", base_env, 180)
rows = {}
font_files = [p for d in os.environ["PROBE_FONT_PATH"].split(":")
              for p in Path(d).rglob("*.otf") if p.name in {"FandolSong-Regular.otf", "FandolSong-Bold.otf", "FandolHei-Regular.otf", "FandolHei-Bold.otf"}]
assert len(font_files) == 4, font_files
register = "\n".join(f"(font-database-extend-local (system->url {json.dumps(str(p))}))"
                       for p in font_files)
register += '\n(call-with-output-file (getenv "PROBE_FONT_DB") (lambda (p) (write (font-database-families) p)))\n'

def prepare_font_environment(env):
    font_dir = Path(env["TEXMACS_HOME_PATH"]) / "fonts/truetype"
    font_dir.mkdir(parents=True, exist_ok=True)
    for font in font_files:
        (font_dir / font.name).symlink_to(font)

for style in ["generic", "article"]:
    for mode, font in [("baseline", ""), ("cjk-default", ""),
                       ("cjk-serif", "FandolSong"), ("cjk-sans", "FandolHei")]:
        name = f"{style}-{mode}"
        print("Running", name, flush=True)
        env = base_env.copy()
        env.update(PROBE_OUT=str(out), PROBE_STYLE=style, PROBE_NAME=name, PROBE_FONT=font, PROBE_FONT_DB=str(out / (name + "-org-fontdb.sexp")))
        if mode != "baseline":
            env["FONTCONFIG_FILE"] = os.environ["PROBE_FONTCONFIG"]
            env["TEXMACS_FONT_PATH"] = os.environ["PROBE_FONT_PATH"]
            run(["fc-list", ":lang=zh", "family", "file"], name + "-font-list", env)
        env["TEXMACS_HOME_PATH"] = str(Path(os.environ["TMPDIR"]) / (name + "-org-config"))
        if mode != "baseline":
            prepare_font_environment(env)
            env["PROBE_REGISTER"] = register
        run([os.environ["EMACS_PROGRAM"], "-Q", "--batch", "--load", export], name + "-export", env)
        for origin in ["native", "reload"]:
            if origin == "reload":
                setup = f"(load-buffer (system->url {json.dumps(str(out / (name + '.tm')))}))"
                end = ""
            else:
                inits = ""
                if font:
                    inits = f'(init-env-tree "font" (stree->tree {json.dumps(font)})) (init-env-tree "language" (stree->tree "chinese"))'
                setup = f'(let ((b (buffer-new))) (view-new b) (with-buffer b (set-style-list (list "{style}")) {inits} (buffer-set-body b (stree->tree \'{scheme(body)}))'
                end = "))"
            pdf = out / f"{name}-{origin}.pdf"
            script = out / f"{name}-{origin}.scm"
            script.write_text('''(use-modules (utils library cursor) (generic document-edit) (generic document-style))
(begin (catch #t (lambda () ''' + (register if mode != 'baseline' else '') + setup + f'''
  (do ((pass 0 (+ pass 1))) ((= pass 2))
    (do ((i 0 (+ i 1))) ((= i 3)) (update-current-buffer))
    (update-forced) (print-to-file (system->url {json.dumps(str(pdf))})))
  (call-with-output-file {json.dumps(str(out / f'{name}-{origin}-native-state.sexp'))}
   (lambda (p) (write (list (tree->stree (buffer-get-body (current-buffer)))
    (tree->stree (get-env-tree "font")) (tree->stree (get-env-tree "language"))) p)))
  {end} (display "BLOCK-FONT-NATIVE-OK\\n"))
  (lambda args (display "BLOCK-FONT-NATIVE-ERROR ") (write args))) (quit-TeXmacs))
''')
            env["TEXMACS_HOME_PATH"] = str(Path(os.environ["TMPDIR"]) / f"{name}-{origin}-config")
            env["PROBE_FONT_DB"] = str(out / f"{name}-{origin}-fontdb.sexp")
            if mode != "baseline":
                prepare_font_environment(env)
            log = run([os.environ["TEXMACS_PROGRAM"], "-H", "-s", "-x",
                       f"(load {json.dumps(str(script))})"], f"{name}-{origin}", env, 45)
            assert b"BLOCK-FONT-NATIVE-OK" in log, name + origin
        for origin in ["org", "native", "reload"]:
            key = f"{name}-{origin}"
            pdf = out / (key + ".pdf")
            text = run(["pdftotext", "-layout", pdf, "-"], key + "-text", env).decode()
            fonts = run(["pdffonts", pdf], key + "-fonts", env).decode()
            xml = run(["pdftohtml", "-xml", "-i", "-hidden", "-stdout", pdf], key + "-xml", env)
            document = ET.fromstring(xml)
            pages = []
            for page in document.findall("page"):
                pages.append({"page": page.attrib, "fonts": [dict(f.attrib) for f in page.findall("fontspec")],
                              "runs": [{**t.attrib, "text": "".join(t.itertext())} for t in page.findall("text")]})
            if origin == "org" and mode in {"cjk-serif", "cjk-sans"}:
                run(["pdftoppm", "-f", "1", "-singlefile", "-scale-to", "1600", "-png",
                     pdf, out / (key + "-page1")], key + "-raster", env)
            rows[key] = {"style": style, "mode": mode, "font": font, "origin": origin,
                         "text": text, "pdf_fonts": fonts, "pages": pages,
                         "has_chinese": "中文测试" in text,
                         "literal_fallback": "<#" in text}
(out / "summary.json").write_text(json.dumps(rows, ensure_ascii=False, indent=2) + "\n")
print("BLOCK-FONT-PROBE-OK", len(rows))
for key, row in rows.items():
    print(key, "real_chinese=" + str(row["has_chinese"]), "fallback=" + str(row["literal_fallback"]))
