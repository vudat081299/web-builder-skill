#!/usr/bin/env bash
# =============================================================================
# wb — read-only locator for the web-builder library (a token-saver, not a gate)
# -----------------------------------------------------------------------------
# /wb-change step 1 *documents* a discipline: `grep <class>` in web-builder.css,
# gather the scattered hits into clusters, then `Read` each cluster by
# offset/limit (never the whole 2900-line file). Today the model does that dance
# by hand every time — grep, eyeball line numbers, do the offset arithmetic. This
# script does the mechanical part and prints the exact `Read` commands to run,
# plus a blast-radius map (which other files mention the term), so discover and
# everyday dogfooding cost far fewer tokens.
#
# It only PRINTS. It never edits, never judges right/wrong, so it cannot block or
# mislead — unlike the §18/coherence auto-checks we deliberately did NOT build
# (they were too noisy on the real CSS; see README "Deliberate trade-offs").
#
# NEVER ships — lives in .claude/, same class as validate-sync.sh. The shipping
# artifact is still only web-builder/assets/web-builder.css.
#
# Usage:
#   wb locate <term>     # cluster CSS hits -> ready-to-run Read offset/limit + blast radius
#   wb classes           # list base wb-* classes the CSS defines (no --modifiers)
#   wb classes --all     # include --modifier classes
# Tunables: WB_GAP (merge hits ≤N lines apart into one cluster, default 8)
#           WB_PAD (context lines padded around each cluster, default 3)
# =============================================================================
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1
A="web-builder/assets"
CSS="$A/web-builder.css"
CAT="web-builder/references/components-catalog.md"
SKILL="web-builder/SKILL.md"
GAP="${WB_GAP:-8}"
PAD="${WB_PAD:-3}"

die() { echo "wb: $*" >&2; exit 1; }
[ -f "$CSS" ] || die "not in the web-builder repo (missing $CSS)"

cmd="${1:-}"; shift 2>/dev/null || true

case "$cmd" in
  locate)
    term="${1:-}"
    [ -n "$term" ] || die "usage: wb locate <term>   (e.g. wb locate wb-input)"

    # 1) All matching line numbers in the shipping CSS (fixed-string substring match,
    #    so `wb-input` also finds `wb-input-group`). Rules are scattered: token in
    #    :root, main block, .dark/:where override, and other components reusing it.
    nums="$(grep -Fn "$term" "$CSS" | cut -d: -f1)"
    if [ -z "$nums" ]; then
      echo "wb locate: no line in $CSS matches '$term'."
      echo "           (try a shorter stem, or 'wb classes' to see what's defined)"
    else
      hits="$(printf '%s\n' "$nums" | grep -c .)"
      echo "── $term · $hits hit(s) in web-builder.css → Read these cluster(s):"
      # 2) Merge contiguous-ish line numbers into clusters (gap ≤ GAP), then
      # 3) emit an exact Read offset/limit (padded) for each — copy-run as-is.
      printf '%s\n' "$nums" | awk -v gap="$GAP" -v pad="$PAD" '
        { n=$1+0
          if (NR==1)            { start=n; prev=n }
          else if (n-prev > gap){ emit(); start=n; prev=n }
          else                  { prev=n }
        }
        END { if (NR>0) emit() }
        function emit(   off,lim) {
          off = start-pad; if (off<1) off=1
          lim = (prev-start) + 2*pad + 1
          printf "  Read web-builder/assets/web-builder.css offset=%d limit=%d   # lines %d–%d\n", off, lim, start, prev
        }'
    fi

    # 4) Blast radius — the other 5 sync places that mention the term, so discover
    #    sees "changing this touches here too" without opening each file.
    echo "── Blast radius (other files mentioning '$term'):"
    found=0
    for f in "$A"/pages/*.html "$CAT" "$SKILL" "$A/app.js"; do
      [ -f "$f" ] || continue
      if grep -Fq "$term" "$f" 2>/dev/null; then
        c="$(grep -Fc "$term" "$f")"
        printf '  %s  (%sx)\n' "$f" "$c"
        found=1
      fi
    done
    [ "$found" -eq 0 ] && echo "  (none elsewhere)"
    ;;

  classes)
    all="${1:-}"
    if [ "$all" = "--all" ]; then
      grep -oE '\.wb-[a-z0-9-]+' "$CSS" | sed 's/^\.//' | sort -u
    else
      grep -oE '\.wb-[a-z0-9-]+' "$CSS" | sed 's/^\.//' | grep -v -- '--' | sort -u
    fi
    ;;

  ""|-h|--help|help)
    sed -n '3,33p' "$0" | grep -vE '^# -+$' | sed 's/^# \{0,1\}//'
    ;;

  *)
    die "unknown command '$cmd' — try: wb locate <term> | wb classes | wb help"
    ;;
esac
