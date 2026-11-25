#!/usr/bin/env python3
"""Jira sprint tickets popup for herdr.

  jira-tickets.py           interactive list: <n> = go to / create workspace, r = refresh, q = quit
  jira-tickets.py list      print the table once and exit
  jira-tickets.py go KEY    go to (or create) the workspace for KEY

Tickets: assigned to you in the open sprint(s).
Workspace for TOR-4634: the first herdr workspace whose label is `tor-4634` or starts with
`tor-4634-`. If none exists, one is created with label `tor-4634-<slug>` and its cwd set to
~/Documents/Tickets/<label>/ (an existing ~/Documents/Tickets/tor-4634* dir is reused).

Credentials: ~/.config/herdr-jira/credentials (chmod 600), KEY=VALUE lines:
  JIRA_URL=https://toradex.atlassian.net
  JIRA_EMAIL=you@toradex.com
  JIRA_API_TOKEN=...
"""
from __future__ import annotations

import base64
import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request

CRED_FILE = os.path.expanduser(os.environ.get("HERDR_JIRA_CREDENTIALS", "~/.config/herdr-jira/credentials"))
CACHE_DIR = os.path.expanduser("~/.cache/herdr-jira")
TICKETS_DIR = os.path.expanduser(os.environ.get("HERDR_JIRA_TICKETS_DIR", "~/Documents/Tickets"))
JQL = os.environ.get(
    "HERDR_JIRA_JQL",
    "assignee = currentUser() AND sprint in openSprints() ORDER BY statusCategory ASC, priority DESC, updated DESC",
)
HERDR = os.environ.get("HERDR_BIN_PATH") or "herdr"
STOPWORDS = {"a", "an", "the", "and", "or", "of", "to", "for", "in", "on", "with", "by", "from", "at", "is", "be", "as"}

C = {"g": "\033[32m", "r": "\033[31m", "y": "\033[33m", "d": "\033[2m", "b": "\033[1m", "c": "\033[36m", "m": "\033[35m", "0": "\033[0m"}


# --------------------------------------------------------------------------- Jira
def creds() -> dict:
    d = {}
    try:
        mode = os.stat(CRED_FILE).st_mode & 0o077
        if mode:
            print(f"{C['y']}warning: {CRED_FILE} is readable by others; run chmod 600 on it{C['0']}")
        with open(CRED_FILE) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, v = line.split("=", 1)
                    d[k.strip()] = v.strip().strip('"').strip("'")
    except FileNotFoundError:
        raise SystemExit(f"missing {CRED_FILE}\n\n{__doc__}")
    for k in ("JIRA_URL", "JIRA_EMAIL", "JIRA_API_TOKEN"):
        if not d.get(k):
            raise SystemExit(f"{CRED_FILE}: {k} is not set")
    d["JIRA_URL"] = d["JIRA_URL"].rstrip("/")
    return d


def api(c: dict, method: str, path: str, body: dict | None = None):
    auth = base64.b64encode(f"{c['JIRA_EMAIL']}:{c['JIRA_API_TOKEN']}".encode()).decode()
    req = urllib.request.Request(
        c["JIRA_URL"] + path,
        method=method,
        data=json.dumps(body).encode() if body is not None else None,
        headers={"Authorization": f"Basic {auth}", "Accept": "application/json", "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        msg = e.read().decode(errors="replace")[:300]
        raise RuntimeError(f"Jira {method} {path}: HTTP {e.code} {msg}") from None


def sprint_field(c: dict) -> str | None:
    """Sprint is a custom field whose id differs per site; look it up once and cache it."""
    path = os.path.join(CACHE_DIR, "sprint-field")
    try:
        with open(path) as f:
            return f.read().strip() or None
    except OSError:
        pass
    fid = None
    for fld in api(c, "GET", "/rest/api/3/field"):
        if (fld.get("schema") or {}).get("custom") == "com.pyxis.greenhopper.jira:gh-sprint":
            fid = fld["id"]
            break
    os.makedirs(CACHE_DIR, exist_ok=True)
    with open(path, "w") as f:
        f.write(fid or "")
    return fid


def fetch() -> dict:
    c = creds()
    sf = sprint_field(c)
    fields = ["summary", "status", "priority", "issuetype"] + ([sf] if sf else [])
    issues, token = [], None
    while True:
        body = {"jql": JQL, "fields": fields, "maxResults": 100}
        if token:
            body["nextPageToken"] = token
        r = api(c, "POST", "/rest/api/3/search/jql", body)
        issues += r.get("issues", [])
        token = r.get("nextPageToken")
        if not token or r.get("isLast", True):
            break
    out = []
    for i in issues:
        f = i["fields"]
        sprints = f.get(sf) or [] if sf else []
        active = [s["name"] for s in sprints if isinstance(s, dict) and s.get("state") == "active"]
        out.append({
            "key": i["key"],
            "summary": f.get("summary") or "",
            "status": (f.get("status") or {}).get("name", "?"),
            "cat": ((f.get("status") or {}).get("statusCategory") or {}).get("key", ""),  # new / indeterminate / done
            "priority": (f.get("priority") or {}).get("name", "-"),
            "type": (f.get("issuetype") or {}).get("name", ""),
            "sprint": ", ".join(active) or (sprints[-1]["name"] if sprints and isinstance(sprints[-1], dict) else "-"),
        })
    d = {"ts": time.time(), "url": c["JIRA_URL"], "issues": out}
    os.makedirs(CACHE_DIR, exist_ok=True)
    tmp = os.path.join(CACHE_DIR, "issues.json.tmp")
    with open(tmp, "w") as fh:
        json.dump(d, fh)
    os.replace(tmp, os.path.join(CACHE_DIR, "issues.json"))
    return d


def load(max_age: float = 300) -> dict:
    try:
        with open(os.path.join(CACHE_DIR, "issues.json")) as f:
            d = json.load(f)
        if time.time() - d["ts"] < max_age:
            return d
    except (OSError, ValueError, KeyError):
        pass
    return fetch()


# --------------------------------------------------------------------------- herdr
def herdr(*args: str) -> dict:
    r = subprocess.run([HERDR, *args], capture_output=True, text=True, timeout=15)
    if r.returncode != 0:
        raise RuntimeError(f"herdr {' '.join(args)}: {r.stderr.strip() or r.stdout.strip()}")
    return json.loads(r.stdout) if r.stdout.strip().startswith("{") else {}


def slugify(key: str, summary: str) -> str:
    words = [w for w in re.findall(r"[a-z0-9]+", summary.lower()) if w not in STOPWORDS]
    slug = ""
    for w in words:
        if len(slug) + len(w) + 1 > 24:
            break
        slug = f"{slug}-{w}" if slug else w
    return f"{key.lower()}-{slug}" if slug else key.lower()


def matches(label: str, key: str) -> bool:
    k = key.lower()
    label = label.lower()
    return label == k or label.startswith(k + "-")


def find_workspace(key: str) -> dict | None:
    for w in herdr("workspace", "list")["result"]["workspaces"]:
        if matches(w.get("label", ""), key):
            return w
    return None


def ticket_dir(key: str, label: str) -> str:
    if os.path.isdir(TICKETS_DIR):
        for name in sorted(os.listdir(TICKETS_DIR)):
            if matches(name, key) and os.path.isdir(os.path.join(TICKETS_DIR, name)):
                return os.path.join(TICKETS_DIR, name)
    path = os.path.join(TICKETS_DIR, label)
    os.makedirs(path, exist_ok=True)
    return path


def go(key: str, summary: str = "") -> str:
    key = key.upper()
    w = find_workspace(key)
    if w:
        herdr("workspace", "focus", w["workspace_id"])
        return f"focused {w['label']}"
    label = slugify(key, summary)
    cwd = ticket_dir(key, label)
    herdr("workspace", "create", "--label", label, "--cwd", cwd, "--focus")
    return f"created {label} in {cwd}"


# --------------------------------------------------------------------------- UI
def fmt_status(i: dict) -> str:
    col = {"new": C["d"], "indeterminate": C["y"], "done": C["g"]}.get(i["cat"], "")
    return f"{col}{i['status'][:14]:<14}{C['0']}"


def fmt_prio(p: str) -> str:
    col = {"Highest": C["r"] + C["b"], "High": C["r"], "Medium": C["y"], "Low": C["d"], "Lowest": C["d"]}.get(p, "")
    return f"{col}{p[:8]:<8}{C['0']}"


def render(d: dict, clear: bool = True) -> list[dict]:
    issues = d["issues"]
    try:
        width = os.get_terminal_size().columns
    except OSError:
        width = 120
    if clear:
        print("\033[2J\033[H", end="")
    age = int(time.time() - d["ts"])
    print(f"{C['b']}Jira: my tickets in open sprints{C['0']}  {C['d']}({len(issues)}, updated {age}s ago){C['0']}\n")
    if not issues:
        print(f"{C['d']}  nothing assigned to you in an open sprint{C['0']}\n")
    sprint_w = min(18, max((len(i["sprint"]) for i in issues), default=6))
    print(f"{C['d']}  # {'KEY':<10} {'STATUS':<14} {'PRIO':<8} {'SPRINT':<{sprint_w}} SUMMARY{C['0']}")
    for n, i in enumerate(issues, 1):
        room = max(10, width - (4 + 11 + 15 + 9 + sprint_w + 2))
        s = i["summary"] if len(i["summary"]) <= room else i["summary"][: room - 1] + "…"
        sp = i["sprint"] if len(i["sprint"]) <= sprint_w else i["sprint"][: sprint_w - 1] + "…"
        dim = C["d"] if i["cat"] == "done" else ""
        print(f"{n:>3} {C['m']}{i['key']:<10}{C['0']} {fmt_status(i)} {fmt_prio(i['priority'])} "
              f"{C['d']}{sp:<{sprint_w}}{C['0']} {dim}{s}{C['0']}")
    print()
    return issues


def interactive() -> None:
    msg = ""
    d = load()
    while True:
        issues = render(d)
        if msg:
            print(msg + "\n")
            msg = ""
        try:
            cmd = input(f"{C['d']}[n] go to workspace · r refresh · q quit >{C['0']} ").strip().lower()
        except (EOFError, KeyboardInterrupt):
            return
        if cmd in ("q", "quit", "exit"):
            return
        if cmd == "r":
            print("refreshing…")
            try:
                d = fetch()
            except Exception as e:  # noqa: BLE001
                msg = f"{C['r']}refresh failed: {e}{C['0']}"
            continue
        if cmd.isdigit() and 1 <= int(cmd) <= len(issues):
            i = issues[int(cmd) - 1]
            try:
                go(i["key"], i["summary"])
                return  # close the popup; herdr now shows the ticket's workspace
            except Exception as e:  # noqa: BLE001
                msg = f"{C['r']}{e}{C['0']}"
            continue
        if cmd:
            msg = f"{C['y']}unknown input: {cmd}{C['0']}"


def main() -> int:
    args = sys.argv[1:]
    mode = args[0] if args else "popup"
    try:
        if mode == "popup":
            interactive()
        elif mode == "list":
            render(fetch(), clear=False)
        elif mode == "go" and len(args) >= 2:
            summary = next((i["summary"] for i in load(max_age=86400)["issues"] if i["key"] == args[1].upper()), "") \
                if os.path.exists(CRED_FILE) else ""
            print(go(args[1], summary))
        else:
            print(__doc__)
            return 2
    except SystemExit as e:
        print(e)
        if mode == "popup":
            input("(enter to close)")
        return 1
    except Exception as e:  # noqa: BLE001
        print(f"error: {e}", file=sys.stderr)
        if mode == "popup":
            input("(enter to close)")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
