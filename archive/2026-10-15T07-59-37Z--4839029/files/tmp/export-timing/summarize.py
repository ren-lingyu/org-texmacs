"""Summarize existing JSON measurements; does not execute Emacs or exports."""
import csv
import json
from pathlib import Path
from statistics import median

base = Path(__file__).parent
rows = []
for factor in (1, 2, 4, 8):
    data = json.loads((base / f"results-{factor}.json").read_text())
    assert len(data["runs"]) == 24
    assert data["metadata"]["factor"] == factor
    rows.extend(data["runs"])
assert len(rows) == 96
assert all(row["error"] is None for row in rows)
summary = []
for factor in (1, 2, 4, 8):
    for route in ("direct", "include"):
        for fmt in ("tm", "pdf"):
            for temperature in ("cold", "warm"):
                group = [r for r in rows if (r["factor"], r["route"], r["format"], r["temperature"]) == (factor, route, fmt, temperature)]
                assert sorted(r["repeat"] for r in group) == [1, 2, 3]
                for r in group:
                    assert sum(s["exclusive_s"] for s in r["stages"]) <= r["elapsed_s"] + 0.001
                names = sorted({s["stage"] for r in group for s in r["stages"]})
                stages = {}
                for name in names:
                    samples = [next((s for s in r["stages"] if s["stage"] == name), {"calls": 0, "inclusive_s": 0, "exclusive_s": 0}) for r in group]
                    stages[name] = {key: median(s[key] for s in samples) for key in ("calls", "inclusive_s", "exclusive_s")}
                summary.append(dict(factor=factor, route=route, format=fmt, temperature=temperature,
                                    expanded_bytes=group[0]["expanded_bytes"],
                                    median_s=median(r["elapsed_s"] for r in group),
                                    min_s=min(r["elapsed_s"] for r in group),
                                    max_s=max(r["elapsed_s"] for r in group),
                                    wait_s=median(sum(s["exclusive_s"] for s in r["stages"] if s["stage"].startswith("wait_")) for r in group),
                                    wait_fraction=median(sum(s["exclusive_s"] for s in r["stages"] if s["stage"].startswith("wait_")) / r["elapsed_s"] for r in group),
                                    gc_count=median(r["gc_count"] for r in group),
                                    gc_s=median(r["gc_s"] for r in group),
                                    residual_s=median(r["elapsed_s"] - sum(s["exclusive_s"] for s in r["stages"]) for r in group),
                                    stages=stages))
(base / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
fields = [key for key in summary[0] if key != "stages"]
with (base / "summary.csv").open("w", newline="") as stream:
    writer = csv.DictWriter(stream, fieldnames=fields)
    writer.writeheader()
    writer.writerows({key: r[key] for key in fields} for r in summary)
for r in summary:
    print(f"{r['factor']:d} {r['route']:7s} {r['format']:3s} {r['temperature']:4s} "
          f"{r['median_s']:.4f}s [{r['min_s']:.4f},{r['max_s']:.4f}] "
          f"wait={100*r['wait_fraction']:.1f}% gc={r['gc_s']:.4f}s")
