# bin/filter_paths.py
import re
import sys

SLUG = sys.argv[1]
CHANGED_FILES = sys.argv[2:]

SLUG_TEMPLATE = r"2026-\d{2}-\d{2}-[a-z0-9][a-z0-9._-]*"

errors = []

if re.fullmatch(SLUG_TEMPLATE, SLUG) is None:
    errors.append(
        f"Your PR title (slug) must match <{SLUG_TEMPLATE}>. Got <{SLUG}>."
    )

slug = re.escape(SLUG)
allowed = [
    rf"_posts/{slug}\.(md|html)$",
    rf"assets/img/{slug}/.*",
    rf"assets/html/{slug}/.*",
    rf"assets/bibliography/{slug}\.bib$",
]

bad = []
for f in CHANGED_FILES:
    if not any(re.fullmatch(p, f) for p in allowed):
        bad.append(f)

if bad:
    errors.append(
        "You may only change:\n"
        "- _posts/SLUG.(md|html)\n"
        "- assets/img/SLUG/...\n"
        "- assets/html/SLUG/...\n"
        "- assets/bibliography/SLUG.bib\n\n"
        "Not allowed:\n" + "\n".join(f"- {x}" for x in bad)
    )

if errors:
    print("PATHFILTERFAILED")
    print("\n".join(errors))
    sys.exit(1)

sys.exit(0)