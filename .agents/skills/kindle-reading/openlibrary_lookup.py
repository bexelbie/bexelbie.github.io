#!/usr/bin/env python3
"""Look up a book on OpenLibrary and print ready-to-paste reading.yml fields.

    openlibrary_lookup.py "The Culture Code"
    openlibrary_lookup.py "Pines" "Blake Crouch"

Queries the OpenLibrary search API for the title (and optional author),
prints up to 5 candidate works (title/author/work key), and for each
candidate resolves a cover image and checks whether it's real or a
placeholder — OpenLibrary returns a 43-byte grey "no cover" GIF for editions
with no actual cover art, so a raw cover_edition_key is not enough to trust.

No dependencies beyond stdlib (urllib, json) — nothing to install.
"""
import json
import sys
import urllib.error
import urllib.parse
import urllib.request

SEARCH_URL = "https://openlibrary.org/search.json"
COVER_URL = "https://covers.openlibrary.org/b/olid/{}-M.jpg"
FIELDS = "title,author_name,key,cover_edition_key,edition_key"
PLACEHOLDER_MAX_BYTES = 100  # real covers are far larger; the "no cover" GIF is ~43 bytes


def search(title, author=None):
    q = f'title:"{title}"'
    if author:
        q += f' author:"{author}"'
    url = f"{SEARCH_URL}?q={urllib.parse.quote(q)}&fields={FIELDS}&limit=5"
    req = urllib.request.Request(url, headers={"User-Agent": "bexelbie-reading-yml/1.0"})
    with urllib.request.urlopen(req) as r:
        return json.load(r).get("docs", [])


def cover_status(edition_key):
    """Return (cover_url, status) where status is 'ok', 'placeholder', or 'none'."""
    if not edition_key:
        return None, "none"
    url = COVER_URL.format(edition_key)
    req = urllib.request.Request(url, headers={"User-Agent": "bexelbie-reading-yml/1.0"})
    try:
        with urllib.request.urlopen(req) as r:
            size = len(r.read())
    except urllib.error.HTTPError as e:
        return url, f"http {e.code}"
    return url, ("placeholder" if size <= PLACEHOLDER_MAX_BYTES else "ok")


def main():
    if len(sys.argv) < 2:
        sys.exit(f"usage: {sys.argv[0]} <title> [author]")
    title = sys.argv[1]
    author = sys.argv[2] if len(sys.argv) > 2 else None

    docs = search(title, author)
    if not docs:
        sys.exit("no OpenLibrary matches")

    for i, doc in enumerate(docs, 1):
        work_key = doc.get("key", "")
        authors = ", ".join(doc.get("author_name", []))
        edition = doc.get("cover_edition_key") or (doc.get("edition_key") or [None])[0]
        cover_url, status = cover_status(edition)

        print(f"[{i}] {doc.get('title')} — {authors or '(no author)'}")
        print(f'    url:   "https://openlibrary.org{work_key}"')
        if cover_url and status == "ok":
            print(f'    cover: "{cover_url}"')
        elif cover_url:
            print(f"    cover: {cover_url}  ({status} — don't use as-is)")
        else:
            print("    cover: none found")
        print()


if __name__ == "__main__":
    main()
