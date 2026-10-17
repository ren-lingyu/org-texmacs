"""Compare recorded native/package text, fonts and geometry without rerendering."""
import json
from pathlib import Path
import re

root = Path(__file__).resolve().parent
rows = json.loads((root / "fandol-results/summary.json").read_text())


def normal(row):
    pages = []
    for page in row["pages"]:
        fonts = {f["id"]: {k: re.sub(r"^[A-Z]{6}\+", "", v) if k == "family" else v
                           for k, v in f.items() if k != "id"} for f in page["fonts"]}
        pages.append([{**{k: v for k, v in run.items() if k != "font"},
                       "font": fonts[run["font"]]} for run in page["runs"]])
    return pages


comparisons = {}
for style in ["generic", "article"]:
    for mode in ["baseline", "cjk-default", "cjk-serif", "cjk-sans"]:
        name = style + "-" + mode
        org, native, reload = (rows[name + "-" + origin] for origin in ["org", "native", "reload"])
        record = {"text_same": org["text"] == native["text"] == reload["text"],
                  "geometry_font_same": normal(org) == normal(native) == normal(reload),
                  "real_chinese": org["has_chinese"], "fallback": org["literal_fallback"]}
        assert record["text_same"] and record["geometry_font_same"], (name, record)
        assert record["real_chinese"] == (mode != "baseline"), (name, record)
        assert record["fallback"] == (mode == "baseline"), (name, record)
        comparisons[name] = record
(root / "comparison.json").write_text(json.dumps(comparisons, indent=2) + "\n")
print("Verified24PDFs:18positive,6missing-font baselines; all8route comparisons match")
