#!/usr/bin/env python3
"""Dev server for the Web Builder docs.

Same as ``python3 -m http.server`` but adds ``Cache-Control: no-store`` to every
response, so edits to ``web-builder.css`` / ``docs.css`` / ``app.js`` / ``pages/*.html``
show up on a plain reload — no hard-refresh (Cmd/Ctrl+Shift+R) needed.

    cd web-builder/assets && python3 serve.py        # http://127.0.0.1:8777
    cd web-builder/assets && python3 serve.py 9000   # a different port
"""
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler


class NoCacheHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store, max-age=0")
        super().end_headers()


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8777
    print(f"Web Builder docs → http://127.0.0.1:{port}  (Cache-Control: no-store)")
    try:
        HTTPServer(("127.0.0.1", port), NoCacheHandler).serve_forever()
    except KeyboardInterrupt:
        pass
