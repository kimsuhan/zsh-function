# Usage: ssh-connect {site-name}
# Example: ssh-connect forlong-core-dev
ssh-connect() {
    local site="$1"
    local sites_file="$HOME/.zshrc_function/data/ssh-sites.json"
    local result
    result="$(python3 - "$site" "$sites_file" <<'PY'
import json
import os
import sys

site = sys.argv[1] if len(sys.argv) > 1 else ""
path = sys.argv[2] if len(sys.argv) > 2 else ""

try:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
except FileNotFoundError:
    print(f"Error: sites file not found: {path}", file=sys.stderr)
    sys.exit(3)
except Exception as exc:
    print(f"Error: failed to parse sites file: {exc}", file=sys.stderr)
    sys.exit(3)

if site and site in data:
    cmd = data.get(site, {}).get("cmd", "")
    if not cmd:
        print(f"Error: no command for site '{site}'", file=sys.stderr)
        sys.exit(3)
    print(cmd)
    sys.exit(0)

items = [(k, data[k].get("desc", "")) for k in sorted(data.keys())]
name_w = max([len("NAME")] + [len(k) for k, _ in items]) if items else len("NAME")
desc_w = max([len("DESCRIPTION")] + [len(d) for _, d in items]) if items else len("DESCRIPTION")

print("Available sites (from ssh-sites.json):")
print(f"{'NAME'.ljust(name_w)}  DESCRIPTION")
print(f"{'-' * name_w}  {'-' * desc_w}")
for name, desc in items:
    print(f"{name.ljust(name_w)}  {desc}")
print("Usage: ssh-connect {site-name}")
sys.exit(1)
PY
)"

    local status_code=$?
    if [ $status_code -eq 0 ]; then
        eval "$result"
        return $?
    fi

    if [ -n "$result" ]; then
        printf '%s\n' "$result"
    fi
    return $status_code
}
