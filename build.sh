#!/usr/bin/env bash
# Wraps the artifact page (which the claude.ai runtime normally supplies a <head> for)
# into a standalone index.html for GitHub Pages. Pass the source page as $1.
set -euo pipefail
SRC="${1:-$HOME/daily-standard/page.html}"
OUT="$HOME/daily-standard/index.html"
{
  cat <<'EOF'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="Standard">
<meta name="theme-color" content="#0d0b13">
<link rel="manifest" href="manifest.webmanifest">
<link rel="apple-touch-icon" href="icon-192.png">
<link rel="icon" href="icon-192.png">
<style>
  :root { padding-top: env(safe-area-inset-top, 0px); padding-bottom: env(safe-area-inset-bottom, 0px); }
  body { margin: 0; font: 14px system-ui, sans-serif; }
  img { max-width: 100%; }
  [hidden] { display: none !important; }
</style>
EOF
  cat "$SRC"
  cat <<'EOF'
<script>
  if ("serviceWorker" in navigator) {
    addEventListener("load", () => navigator.serviceWorker.register("sw.js").catch(() => {}));
  }
</script>
</body>
</html>
EOF
} > "$OUT.tmp"
python3 - "$OUT" <<'PY'
import sys
out = sys.argv[1]
s = open(out + ".tmp").read()
assert '<div class="wrap">' in s
s = s.replace('<div class="wrap">', '</head>\n<body>\n<div class="wrap">', 1)
open(out, "w").write(s)
print(out, len(s), "bytes")
PY
rm "$OUT.tmp"
cp "$SRC" "$HOME/daily-standard/page.html"
cp "$OUT" "$HOME/daily-standard.html"
