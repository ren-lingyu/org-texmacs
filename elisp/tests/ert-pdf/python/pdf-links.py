"""Inspect actual PDF destinations and Poppler text boxes for native ERT tests."""

import json
import subprocess
import sys
import xml.etree.ElementTree as ET

from pypdf import PdfReader


def inspect(filename, links_only=False):
    reader = PdfReader(filename)

    def point(page, x, y):
        if page is None or x is None or y is None:
            return None
        return {
            "page": page + 1,
            "x": float(x),
            "y": float(reader.pages[page].mediabox.height) - float(y),
        }

    named = {
        str(key): point(reader.get_destination_page_number(dest), dest.left, dest.top)
        for key, dest in reader.named_destinations.items()
    }

    def resolve(dest):
        if isinstance(dest, (str, bytes)):
            key = dest.decode() if isinstance(dest, bytes) else str(dest)
            return named.get(key) or named.get(key.lstrip("/")) or named.get("/" + key)
        if isinstance(dest, list) and len(dest) >= 5 and str(dest[1]) == "/XYZ":
            page = next(
                (i for i, p in enumerate(reader.pages) if p.indirect_reference == dest[0]), None
            )
            return point(page, dest[2], dest[3])
        return None

    links = []
    for page_number, page in enumerate(reader.pages, 1):
        height = float(page.mediabox.height)
        for ref in page.get("/Annots", []):
            annotation = ref.get_object()
            if annotation.get("/Subtype") != "/Link":
                continue
            action = annotation.get("/A")
            action = action.get_object() if action is not None else {}
            dest = annotation.get("/Dest", action.get("/D"))
            x1, y1, x2, y2 = map(float, annotation["/Rect"])
            links.append(
                {
                    "page": page_number,
                    "rect": [x1, height - y2, x2, height - y1],
                    "target": resolve(dest),
                    "uri": str(action["/URI"]) if "/URI" in action else None,
                }
            )

    if links_only:
        return {"links": links}

    xml = subprocess.run(
        ["pdftohtml", "-xml", "-i", "-hidden", "-stdout", filename],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    texts = []
    for page in ET.fromstring(xml.stdout).findall("page"):
        for text in page.findall("text"):
            x, y, width, height = (
                float(text.attrib[key]) / 1.5 for key in ("left", "top", "width", "height")
            )
            texts.append(
                {
                    "page": int(page.attrib["number"]),
                    "rect": [x, y, x + width, y + height],
                    "text": "".join(text.itertext()),
                }
            )
    return {"links": links, "texts": texts}


if __name__ == "__main__":
    json.dump(inspect(sys.argv[1], "--links-only" in sys.argv[2:]), sys.stdout)
    print()
