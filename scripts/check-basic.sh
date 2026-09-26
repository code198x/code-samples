#!/usr/bin/env bash
# Check every BASIC listing the website builds, the way the website builds it.
#
# The website's deploy (code198x/website scripts/build-artefacts.sh) runs
# `make` in every BASIC unit folder, and one failing listing stops the whole
# deploy. This runs the same checks here first, so a bad listing fails its
# own pull request instead:
#
#   1. `build198x basic lint` over both machines' listings, plus the CRASH!
#      Live type-ins and welcome and the Foundations Spectrum captures, which
#      are shown or typed but have no Makefile.
#   2. `make` in every BASIC unit folder (`*/basic/*/unit-*/Makefile`).
#
# It uses whatever `build198x` is on PATH; CI installs the pinned release
# (BUILD198X_VERSION in .github/workflows/basic-listings.yml).
#
# Usage: scripts/check-basic.sh

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Listings that fail lint on purpose, because the lesson shows the machine
# refusing them. Each is still built by no Makefile.
EXCLUDE=(
    # Ruling R-name$: `name$` is illegal on the Spectrum, and the lesson shows
    # the ROM refusing it. basic-reference/unit-04 builds step-01 instead.
    sinclair-zx-spectrum/basic/meet-basic/unit-04/steps/step-03.bas
    # The lesson shows CASH and CARD being one variable on the C64, because
    # BASIC V2 reads only the first two characters. Its Makefile builds step-03.
    commodore-64/basic/meet-c64-basic/unit-04/steps/step-02.bas
)

listings() {
    git ls-files -- "$@" | grep -vxF -f <(printf '%s\n' "${EXCLUDE[@]}")
}

# Foundations listings are captured on the machine their manifest names.
foundations_spectrum() {
    python3 - <<'PYEOF'
import json, pathlib
for manifest in sorted(pathlib.Path('foundations').glob('**/capture/manifest.json')):
    data = json.loads(manifest.read_text())
    if data.get('machine') == 'sinclair-zx-spectrum':
        for capture in data['captures']:
            print((manifest.parent.parent / capture['program']).as_posix())
PYEOF
}

failed=0

echo "Linting Spectrum listings..."
zx=()
while IFS= read -r f; do zx+=("$f"); done < <(
    listings 'sinclair-zx-spectrum/*.bas' \
        _capture/crash-live/typein-198x.bas _capture/crash-live/typein-rosette.bas \
        _capture/crash-live/welcome.bas
    foundations_spectrum | sort -u
)
build198x basic lint --machine sinclair-zx-spectrum "${zx[@]}" || failed=1
echo "  ${#zx[@]} files"

echo "Linting C64 listings..."
c64=()
while IFS= read -r f; do c64+=("$f"); done < <(
    listings 'commodore-64/*.bas' _capture/crash-live/typein-198x-c64.bas
)
build198x basic lint --machine commodore-c64 "${c64[@]}" || failed=1
echo "  ${#c64[@]} files"

echo "Building every BASIC unit..."
built=0
while IFS= read -r makefile; do
    dir="$(dirname "$makefile")"
    if ! make -s -C "$dir" >/dev/null; then
        echo "FAILED: $dir"
        failed=1
    fi
    built=$((built + 1))
done < <(git ls-files -- '*/basic/*/unit-*/Makefile')
echo "  $built units"

if [ "$failed" != 0 ]; then
    echo "BASIC check failed; see above." >&2
    exit 1
fi
echo "All BASIC listings pass lint and build."
