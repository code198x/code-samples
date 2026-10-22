#!/bin/bash
#
# C64 BASIC Validation Script
#
# Runs comprehensive validation on C64 BASIC files:
# 1. Syntax validation with petcat
# 2. Semantic validation with validate-c64-basic.py
#
# Usage: validate-bas.sh <file.bas>
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check arguments
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $(basename "$0") <file.bas> [--negative-fixture]"
    exit 1
fi

BASFILE="$1"
VALIDATOR_ARGS=()
if [ "$#" -eq 2 ]; then
    if [ "$2" != "--negative-fixture" ]; then
        echo "Unknown validation option: $2" >&2
        exit 1
    fi
    VALIDATOR_ARGS+=("$2")
fi

# Check file exists
if [ ! -f "$BASFILE" ]; then
    echo -e "${RED}❌ File not found: $BASFILE${NC}"
    exit 1
fi

echo "🔍 Validating: $BASFILE"
echo

# Step 1: petcat syntax validation
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Syntax Validation (petcat)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TEMPPRG=$(mktemp /tmp/validate-XXXXXX.prg)
trap "rm -f $TEMPPRG" EXIT

if ! PETCAT_OUTPUT=$(petcat -w2 -o "$TEMPPRG" -- "$BASFILE" 2>&1); then
    echo "$PETCAT_OUTPUT" >&2
    echo 'petcat failed' >&2
    exit 1
fi
if [ ! -s "$TEMPPRG" ]; then
    echo 'petcat produced no program' >&2
    exit 1
fi
if printf '%s\n' "$PETCAT_OUTPUT" | grep -qi 'error'; then
    echo -e "${RED}❌ Syntax validation FAILED${NC}"
    petcat -w2 -o "$TEMPPRG" -- "$BASFILE"
    exit 1
else
    echo -e "${GREEN}✅ Syntax validation passed${NC}"
fi

echo

# Step 2: Semantic validation
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Semantic Validation (C64 BASIC V2)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if python3 "$SCRIPT_DIR/validate-c64-basic.py" "$BASFILE" "${VALIDATOR_ARGS[@]}"; then
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}✅ ALL VALIDATION PASSED${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
else
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${RED}❌ VALIDATION FAILED${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi
