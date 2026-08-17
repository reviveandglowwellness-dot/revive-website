#!/bin/sh
# Screenshots a vertical slice of a rendered book/preview page, so long
# documents can be reviewed a screenful at a time. Chrome headless cannot
# scroll, so the target page is embedded in an iframe that is pulled upward by
# the requested offset.
#
#   ./slice.sh <html-file> <y-offset-px> <height-px> <out.png>
#
# Must run with the Bash tool's sandbox disabled (Chrome cannot write otherwise).

set -e
SRC="$1"; OFF="${2:-0}"; H="${3:-1150}"; OUT="$4"
TMP="$(dirname "$OUT")/_slice.html"

cat > "$TMP" <<EOF
<!doctype html><html><head><meta charset="utf-8"><style>
  html,body { margin:0; background:#9a9a9a; overflow:hidden; }
  .win { position:relative; width:816px; height:${H}px; overflow:hidden; margin:0 auto; }
  iframe { position:absolute; top:-${OFF}px; left:0; width:816px; height:40000px; border:0; background:#fff; }
</style></head><body>
  <div class="win"><iframe src="file:///${SRC}" scrolling="no"></iframe></div>
</body></html>
EOF

"C:/Program Files/Google/Chrome/Application/chrome.exe" --headless --disable-gpu --no-sandbox \
  --hide-scrollbars --window-size=816,"$H" --virtual-time-budget=20000 \
  --screenshot="$OUT" "file:///$(echo "$TMP" | sed 's|^/\([a-z]\)/|\1:/|')" 2>&1 | tail -1
