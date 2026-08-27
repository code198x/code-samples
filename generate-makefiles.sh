#!/bin/bash
# Regenerate the checked-in unit Makefiles from one template per platform.
#
# The point is that a unit's Makefile is not hand-maintained: change the
# template here, run this, and every unit follows. What it must never do is
# invent a Makefile. Only directories that already have one are rewritten.
#
# That contract is deliberate. Most units have no Makefile and should not:
# Spectrum's 61 assembly units build through the capture harness, the BASIC
# and AMOS tracks are not assembled at all, and a generator that walked the
# tree looking for source would have created dozens of files nobody asked for.
#
# A Makefile carrying targets this script does not emit is left alone and
# reported, so a unit that has grown its own verification or emulator wiring
# cannot be silently flattened back to the template.
#
# Usage: ./generate-makefiles.sh [--check]
#   --check  report what would change and exit non-zero, writing nothing.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK=0
[ "${1:-}" = "--check" ] && CHECK=1

changed=0
skipped=0
written=0

# Emit $2 as $1's Makefile, unless it carries targets we do not know about.
emit() {
    local path="$1" body="$2"
    local known="all run clean" extra=""
    while read -r t; do
        case " $known " in *" $t "*) ;; *) extra="$extra $t" ;; esac
    done < <(grep -oE '^[a-zA-Z][a-zA-Z0-9_-]*:' "$path" 2>/dev/null | tr -d ':')
    if [ -n "$extra" ]; then
        echo "  skipped $(dirname "${path#"$SCRIPT_DIR"/}") — has its own targets:$extra"
        skipped=$((skipped + 1))
        return
    fi
    # Compared byte for byte, via the same bytes that would be written.
    # A string comparison cannot see a missing trailing newline, because
    # `$(...)` strips it from both sides — so a file that had lost one
    # would never be repaired.
    local tmp
    tmp="$(mktemp)"
    printf '%s\n' "$body" > "$tmp"
    if cmp -s "$tmp" "$path"; then
        rm -f "$tmp"
        return
    fi
    changed=$((changed + 1))
    if [ "$CHECK" = 1 ]; then
        echo "  would rewrite $(dirname "${path#"$SCRIPT_DIR"/}")"
        rm -f "$tmp"
    else
        # Written through the existing file rather than moved over it, so
        # it keeps its mode; mktemp creates 0600 and Makefiles are 0644.
        cat "$tmp" > "$path"
        rm -f "$tmp"
        written=$((written + 1))
    fi
}

# The source a single-source unit builds, e.g. `exodus.asm`.
unit_source() {
    basename "$(ls "$1"/*.asm 2>/dev/null | head -1)" 2>/dev/null
}

c64_makefile() {
    local dir="$1"
    # Cumulative-step units build every step; the last one is the finished
    # program. They have no `run`, because there are several programs.
    if [ -d "$dir/steps" ]; then
        cat <<'EOF'
# Build every cumulative step. The last step is the complete unit program.
ASM ?= asm198x
ASMFLAGS = --dialect acme --prg
STEPS = $(wildcard steps/*.asm)
PRGS  = $(STEPS:.asm=.prg)

all: $(PRGS)

steps/%.prg: steps/%.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f steps/*.prg

.PHONY: all clean
EOF
        return
    fi
    local src name
    src="$(unit_source "$dir")"; name="${src%.asm}"
    cat <<EOF
# Commodore 64 Makefile — built with Asm198x
ASM ?= asm198x
SRC  = ${name}.asm
OUT  = ${name}.prg

.PHONY: all run clean

# Asm198x's acme dialect emits a .prg (2-byte load address prepended).
# Byte-identical to the retired ACME Docker build (verified 2026-07-09).
all: \$(OUT)

\$(OUT): \$(SRC)
	\$(ASM) --dialect acme --prg \$(SRC) -o \$(OUT)

run: \$(OUT)
	x64sc \$(OUT)

clean:
	rm -f \$(OUT)
EOF
}

nes_makefile() {
    local src name
    src="$(unit_source "$1")"; name="${src%.asm}"
    cat <<EOF
# NES Makefile — built with Asm198x
ASM ?= asm198x
SRC  = ${name}.asm
ROM  = ${name}.nes

.PHONY: all run clean

# Asm198x's ca65 dialect assembles and links to an iNES ROM in one step — its
# own bounded ld65 config, no external nes.cfg. Byte-identical to the retired
# ca65 + ld65 Docker build (verified 2026-07-09).
all: \$(ROM)

\$(ROM): \$(SRC)
	\$(ASM) --dialect ca65 \$(SRC) -o \$(ROM)

run: \$(ROM)
	fceux \$(ROM)

clean:
	rm -f \$(ROM)
EOF
}

amiga_makefile() {
    local src name disk
    src="$(unit_source "$1")"; name="${src%.asm}"
    # The volume label names the game, not the source file. A track's units
    # each build a differently-named program — meet-the-machine's unit 13 is
    # `subroutine.asm` — but they all master a disk called MeetTheMachine.
    disk="$(basename "$(dirname "$1")" | awk -F- '{for (i=1; i<=NF; i++) printf toupper(substr($i,1,1)) substr($i,2)}')"
    cat <<EOF
# Commodore Amiga Makefile — family-native, deterministic toolchain
ASM ?= asm198x
BUILD ?= build198x
SRC = ${name}.asm
EXE = ${name}
ADF = ${name}.adf
NAME = ${disk}

.PHONY: all run clean

all: \$(ADF)

# Asm198x's vasm dialect emits the Amiga hunk executable that AmigaDOS loads,
# matching \`vasmm68k_mot -Fhunkexe -kick1hunks -nosym\`.
\$(EXE): \$(SRC)
	\$(ASM) --dialect vasm --exe \$(SRC) -o \$(EXE)

# Build198x masters the bootable OFS floppy: boot block, s/startup-sequence,
# and the executable. Same bytes on every run, unlike a wall-clock timestamp.
\$(ADF): \$(EXE)
	\$(BUILD) adf \$(EXE) -o \$(ADF) --volume \$(NAME) --name \$(EXE)

run: \$(ADF)
	fs-uae --floppy_drive_0=\$(ADF)

clean:
	rm -f \$(EXE) \$(ADF)
EOF
}

while IFS= read -r mk; do
    dir="$(dirname "$mk")"
    case "${mk#"$SCRIPT_DIR"/}" in
        commodore-64/*)                  emit "$mk" "$(c64_makefile "$dir")" ;;
        nintendo-entertainment-system/*) emit "$mk" "$(nes_makefile "$dir")" ;;
        commodore-amiga/*)               emit "$mk" "$(amiga_makefile "$dir")" ;;
        *) ;;   # Spectrum's only Makefile is a hand-written test harness.
    esac
done < <(find "$SCRIPT_DIR" -name Makefile -not -path "*/_*" | sort)

if [ "$CHECK" = 1 ]; then
    [ "$changed" = 0 ] && echo "Makefiles are current." || echo "$changed Makefile(s) out of date."
    [ "$skipped" -gt 0 ] && echo "$skipped left alone."
    exit $(( changed > 0 ))
fi
echo "Rewrote $written Makefile(s); $skipped left alone."
