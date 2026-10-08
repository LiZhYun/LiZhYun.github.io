#!/usr/bin/env python3
"""Reads the citation count and h-index from the Google Scholar profile in
_data/profile.yml and writes them back if they changed.

Exit codes: 0 = file updated, 10 = no change, 20 = Scholar could not be read
(blocked, or the page layout changed). Nothing is written on 10 or 20.
"""
import datetime
import pathlib
import re
import sys
import urllib.request

PROFILE = pathlib.Path(__file__).resolve().parent.parent / "_data" / "profile.yml"
UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36"


def main() -> int:
    text = PROFILE.read_text(encoding="utf-8")
    url = re.search(r"^scholar_url:\s*(\S+)", text, re.M).group(1)
    old_c = int(re.search(r"^  citations:\s*(\d+)", text, re.M).group(1))
    old_h = int(re.search(r"^  h_index:\s*(\d+)", text, re.M).group(1))
    try:
        req = urllib.request.Request(url + "&hl=en", headers={"User-Agent": UA})
        html = urllib.request.urlopen(req, timeout=30).read().decode("utf-8", "replace")
    except Exception as exc:  # network error or HTTP block
        print(f"Scholar not reachable: {exc}")
        return 20
    # The stats table holds: citations (all, recent), h-index (all, recent), i10 (all, recent).
    cells = re.findall(r'gsc_rsb_std">(\d+)<', html)
    if len(cells) < 3:
        print("Scholar page had no stats table (blocked or layout changed)")
        return 20
    new_c, new_h = int(cells[0]), int(cells[2])
    # A sudden drop means a bad read, not a real change.
    if new_c < old_c or new_h < old_h:
        print(f"Ignoring lower numbers ({new_c}/{new_h} vs {old_c}/{old_h})")
        return 20
    if (new_c, new_h) == (old_c, old_h):
        print(f"No change ({old_c} citations, h-index {old_h})")
        return 10
    today = datetime.date.today().isoformat()
    text = re.sub(r"^(  citations:\s*)\d+", rf"\g<1>{new_c}", text, flags=re.M)
    text = re.sub(r"^(  h_index:\s*)\d+", rf"\g<1>{new_h}", text, flags=re.M)
    text = re.sub(r"^(  updated:\s*)\S+", rf"\g<1>{today}", text, flags=re.M)
    PROFILE.write_text(text, encoding="utf-8")
    print(f"Updated: {old_c}->{new_c} citations, h-index {old_h}->{new_h}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
