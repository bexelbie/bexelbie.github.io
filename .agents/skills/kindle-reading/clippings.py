#!/usr/bin/env python3
"""Pull Kindle highlights/notes and dump them by book, ready for reading.yml.

Two stages (pulls My Clippings.txt straight off the Kindle over WiFi):
    clippings.py                     # stage 1: list every book with clippings
    clippings.py "gentoo" "kahneman" # stage 2: dump the ones you pick

Each arg is a case-insensitive title substring; pass as many as you want.
Output tags every entry [Highlight] or [Note] so a quote is distinguishable
from your own note.

Reads a local file instead of the Kindle if you pass one:
    clippings.py --file MyClippings.txt "gentoo"

Needs `dbclient` (brew install dropbear) and `op` signed in. The Kindle is at a
static IP; if the pull fails it's asleep — wake it. The root password lives in
1Password (the item UID below is not a secret; the password never leaves op).
"""
import re
import subprocess
import sys

KINDLE_IP = "172.21.233.5"
CLIPPINGS_PATH = "/mnt/us/documents/My Clippings.txt"
OP_PASSWORD_REF = "op://Private/chtchgdbdwbxnoz3x2r46ixt5q/password"  # "Dominika's Kindle"

# ponytail: My Clippings.txt is the whole model. .mbp byte-offset pipeline is
# Instapaper-only (many articles per file); real books are already one title
# per block, so it's YAGNI here.

LOC = re.compile(r"-\s*(\w+)\s+Loc\.\s*([\d-]+)\s*\|\s*Added on\s*(.+)")


def pull_from_kindle():
    """SSH to the Kindle with an op-supplied password; return the clippings text."""
    pw = subprocess.run(
        ["op", "read", OP_PASSWORD_REF], capture_output=True, text=True
    )
    if pw.returncode:
        sys.exit(f"op read failed (signed in?): {pw.stderr.strip()}")
    # dbclient stdout is binary-safe (banner goes to stderr); cat the file over it.
    r = subprocess.run(
        ["dbclient", "-y", "-y", f"root@{KINDLE_IP}",
         f'cat "{CLIPPINGS_PATH}"'],
        capture_output=True, text=True,
        env={"DROPBEAR_PASSWORD": pw.stdout.strip(), "PATH": "/usr/bin:/bin:/usr/local/bin"},
    )
    if r.returncode or not r.stdout:
        sys.exit(f"Kindle pull failed (asleep? on WiFi?): {r.stderr.strip()}")
    return r.stdout


def parse(text):
    for raw in text.split("=========="):
        lines = [l.strip("\r") for l in raw.strip("\r\n").split("\n")]
        if len(lines) < 2 or not lines[0].strip():
            continue
        title = lines[0].strip("\ufeff \t")
        m = LOC.match(lines[1].strip())
        kind = m.group(1) if m else "?"
        loc = m.group(2) if m else "?"
        added = m.group(3).strip() if m else "?"
        body = "\n".join(lines[2:]).strip()
        yield {"title": title, "kind": kind, "loc": loc, "added": added, "body": body}


def split_author(title):
    m = re.match(r"^(.*?)\s*\(([^()]+)\)\s*$", title)
    return (m.group(1).strip(), m.group(2).strip()) if m else (title, "")


def main():
    args = sys.argv[1:]
    if args and args[0] == "--file":
        if len(args) < 2:
            sys.exit("--file needs a path")
        text = open(args[1], encoding="utf-8-sig").read()
        needles = args[2:]
    else:
        text = pull_from_kindle()
        needles = args

    entries = list(parse(text))

    if not needles:
        seen = {}
        for e in entries:
            seen[e["title"]] = seen.get(e["title"], 0) + 1
        print("Books with clippings (count):\n")
        for t, c in sorted(seen.items(), key=lambda x: -x[1]):
            print(f"  {c:3}  {t}")
        print('\nRun again with one or more title substrings to dump those books.')
        return

    for needle in needles:
        dump(entries, needle)


def dump(entries, needle):
    hits = [e for e in entries if needle.lower() in e["title"].lower()]
    if not hits:
        print(f"\nNo clippings match {needle!r}.", file=sys.stderr)
        return
    title, author = split_author(hits[0]["title"])
    highlights = sum(1 for e in hits if e["kind"] == "Highlight")
    notes = sum(1 for e in hits if e["kind"] == "Note")
    print("=" * 60)
    print(f"Title:  {title}")
    print(f"Author: {author or '(unknown)'}")
    print(f"Clippings: {len(hits)}  ({highlights} highlights, {notes} notes)")
    print("=" * 60)
    for e in hits:
        print(f"\n[{e['kind']}] Loc. {e['loc']}  ({e['added']})")
        print(e["body"] or "(no text — bookmark or empty)")


if __name__ == "__main__":
    main()
