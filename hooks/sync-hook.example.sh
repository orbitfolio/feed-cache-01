#!/bin/bash
# Example hook: pull a public git repo with no credentials, compare the feed
# hash to a locally stored value, and print the payload only when it changes.
# Exit 0 with no output when nothing is new.
set -euo pipefail

REPO_URL="${FEED_CACHE_REPO:-https://github.com/orbitfolio/feed-cache-01.git}"
REPO_DIR="${FEED_CACHE_DIR:-$HOME/feed-cache-01}"
ITEMS_REL="${FEED_CACHE_ITEMS:-data/items.json}"
SEEN_FILE="${FEED_CACHE_SEEN:-$HOME/.feed-cache-01.seen}"
ITEMS_FILE="${REPO_DIR}/${ITEMS_REL}"

if [[ ! -d "${REPO_DIR}/.git" ]]; then
  git clone --depth 1 "${REPO_URL}" "${REPO_DIR}"
else
  git -C "${REPO_DIR}" pull --ff-only --quiet
fi

if [[ ! -f "${ITEMS_FILE}" ]]; then
  exit 0
fi

python3 - "${ITEMS_FILE}" "${SEEN_FILE}" << 'PY'
import json, sys
from pathlib import Path

items_path = Path(sys.argv[1])
seen_path = Path(sys.argv[2])
data = json.loads(items_path.read_text(encoding="utf-8"))
items = data.get("items") or []
current_hash = data.get("hash") or ""
if not items or not current_hash:
    sys.exit(0)
last_hash = seen_path.read_text(encoding="utf-8").strip() if seen_path.exists() else ""
if current_hash == last_hash:
    sys.exit(0)
payload = {
    "hash": current_hash,
    "updated_at": data.get("updated_at"),
    "newest_id": data.get("newest_id"),
    "count": len(items),
    "items": items,
}
print(json.dumps(payload, ensure_ascii=False))
# After the payload has been handled, write current_hash to the seen file.
PY
