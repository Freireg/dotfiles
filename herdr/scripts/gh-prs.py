#!/usr/bin/env python3
"""GitHub PR watchlist for herdr.

  gh-prs.py status   one-line summary for [ui].tab_bar_right (cached)
  gh-prs.py list     interactive table for a popup (r=refresh, <n>=open, q=quit)

Watchlist = open PRs that involve you (author, reviewer, assignee, mentioned,
commented) via GitHub search `involves:@me`.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import time

CACHE = os.path.expanduser("~/.cache/herdr-gh-prs.json")
MAX_AGE = 90  # seconds; status bar polls every 120s

QUERY = """
query {
  viewer { login }
  involved: search(query: "is:pr is:open involves:@me archived:false", type: ISSUE, first: 100) {
    issueCount
    nodes { ... on PullRequest {
      number title url isDraft reviewDecision updatedAt
      author { login }
      repository { nameWithOwner }
      commits(last: 1) { nodes { commit { statusCheckRollup { state } } } }
    } }
  }
  toReview: search(query: "is:pr is:open review-requested:@me archived:false", type: ISSUE, first: 100) {
    nodes { ... on PullRequest { url } }
  }
}
"""


def fetch() -> dict:
    out = subprocess.run(
        ["gh", "api", "graphql", "-f", f"query={QUERY}"],
        capture_output=True, text=True, timeout=25,
    )
    if out.returncode != 0:
        raise RuntimeError(out.stderr.strip() or "gh failed")
    data = json.loads(out.stdout)["data"]
    me = data["viewer"]["login"]
    pending = {n["url"] for n in data["toReview"]["nodes"] if n}
    prs = []
    for n in data["involved"]["nodes"]:
        if not n:
            continue
        roll = n["commits"]["nodes"][0]["commit"]["statusCheckRollup"] if n["commits"]["nodes"] else None
        author = (n.get("author") or {}).get("login", "?")
        prs.append({
            "repo": n["repository"]["nameWithOwner"],
            "number": n["number"],
            "title": n["title"],
            "url": n["url"],
            "draft": n["isDraft"],
            "review": n["reviewDecision"],  # APPROVED / CHANGES_REQUESTED / REVIEW_REQUIRED / None
            "ci": roll["state"] if roll else None,  # SUCCESS / FAILURE / ERROR / PENDING / EXPECTED / None
            "author": author,
            "role": "mine" if author == me else ("review" if n["url"] in pending else "involved"),
            "updated": n["updatedAt"],
        })
    result = {"ts": time.time(), "me": me, "total": data["involved"]["issueCount"], "prs": prs}
    os.makedirs(os.path.dirname(CACHE), exist_ok=True)
    tmp = CACHE + ".tmp"
    with open(tmp, "w") as f:
        json.dump(result, f)
    os.replace(tmp, CACHE)
    return result


def load(max_age: float = MAX_AGE) -> dict:
    try:
        with open(CACHE) as f:
            d = json.load(f)
        if time.time() - d["ts"] < max_age:
            return d
    except (OSError, ValueError, KeyError):
        pass
    return fetch()


def ci_bad(p: dict) -> bool:
    return p["ci"] in ("FAILURE", "ERROR")


def status() -> None:
    d = load()
    prs = d["prs"]
    mine = [p for p in prs if p["role"] == "mine" and not p["draft"]]
    parts = [f"PR {d['total']}"]
    m = f"mine {len(mine)}"
    ok = sum(p["review"] == "APPROVED" for p in mine)
    chg = sum(p["review"] == "CHANGES_REQUESTED" for p in mine)
    sub = " ".join(s for s in (f"✓{ok}" if ok else "", f"✗{chg}" if chg else "") if s)
    parts.append(f"{m} {sub}".strip())
    rev = sum(p["role"] == "review" for p in prs)
    if rev:
        parts.append(f"review {rev}")
    bad = sum(ci_bad(p) for p in prs if p["role"] == "mine")
    if bad:
        parts.append(f"CI✗ {bad}")
    print(" ".join(["⎇"] + [" · ".join(parts)]))


C = {"g": "\033[32m", "r": "\033[31m", "y": "\033[33m", "d": "\033[2m", "b": "\033[1m", "c": "\033[36m", "0": "\033[0m"}


def fmt_review(p: dict) -> str:
    return {
        "APPROVED": f"{C['g']}✓ approved{C['0']}",
        "CHANGES_REQUESTED": f"{C['r']}✗ changes {C['0']}",
        "REVIEW_REQUIRED": f"{C['y']}… pending {C['0']}",
    }.get(p["review"], f"{C['d']}- none    {C['0']}")


def fmt_ci(p: dict) -> str:
    return {
        "SUCCESS": f"{C['g']}✓{C['0']}",
        "FAILURE": f"{C['r']}✗{C['0']}",
        "ERROR": f"{C['r']}!{C['0']}",
        "PENDING": f"{C['y']}●{C['0']}",
        "EXPECTED": f"{C['y']}●{C['0']}",
    }.get(p["ci"], f"{C['d']}·{C['0']}")


def render(d: dict) -> list[dict]:
    order = {"review": 0, "mine": 1, "involved": 2}
    prs = sorted(d["prs"], key=lambda p: (order[p["role"]], p["draft"], p["updated"]), reverse=False)
    # newest first inside each group
    groups: dict[str, list] = {}
    for p in prs:
        groups.setdefault(p["role"], []).append(p)
    titles = {"review": "Waiting for your review", "mine": "Your PRs", "involved": "Involved / mentioned"}
    try:
        width = os.get_terminal_size().columns
    except OSError:
        width = 120
    print("\033[2J\033[H", end="")
    age = int(time.time() - d["ts"])
    print(f"{C['b']}GitHub PRs involving @{d['me']}{C['0']}  {C['d']}({d['total']} open, updated {age}s ago){C['0']}\n")
    flat = []
    for role in ("review", "mine", "involved"):
        items = sorted(groups.get(role, []), key=lambda p: p["updated"], reverse=True)
        if not items:
            continue
        print(f"{C['c']}{titles[role]} ({len(items)}){C['0']}")
        for p in items:
            flat.append(p)
            i = len(flat)
            repo = p["repo"].split("/", 1)[-1] if p["repo"].startswith("torizon/") else p["repo"]
            ref = f"{repo}#{p['number']}"
            draft = f"{C['d']}[draft]{C['0']} " if p["draft"] else ""
            who = "" if role == "mine" else f"{C['d']}@{p['author']}{C['0']} "
            fixed = 4 + 1 + 28 + 1 + 10 + 3
            room = max(10, width - fixed - len(p["author"]) - 4)
            title = p["title"] if len(p["title"]) <= room else p["title"][: room - 1] + "…"
            print(f"{i:>3} {fmt_ci(p)} {ref:<28} {fmt_review(p)} {draft}{who}{title}")
        print()
    return flat


def interactive() -> None:
    d = load()
    while True:
        flat = render(d)
        try:
            cmd = input(f"{C['d']}[n] open in browser · r refresh · q quit >{C['0']} ").strip().lower()
        except (EOFError, KeyboardInterrupt):
            return
        if cmd in ("q", "quit", "exit"):
            return
        if cmd == "r":
            print("refreshing…")
            try:
                d = fetch()
            except Exception as e:  # noqa: BLE001
                input(f"refresh failed: {e} (enter)")
            continue
        if cmd.isdigit() and 1 <= int(cmd) <= len(flat):
            url = flat[int(cmd) - 1]["url"]
            subprocess.Popen(["xdg-open", url], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                             start_new_session=True)


def main() -> int:
    mode = sys.argv[1] if len(sys.argv) > 1 else "status"
    try:
        if mode == "status":
            status()
        elif mode == "list":
            interactive()
        elif mode == "refresh":
            fetch()
        else:
            print(__doc__)
            return 2
    except Exception as e:  # noqa: BLE001
        if mode == "status":
            print(f"⎇ PR ? ({type(e).__name__})")
            return 0
        print(f"error: {e}", file=sys.stderr)
        input("(enter to close)")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
