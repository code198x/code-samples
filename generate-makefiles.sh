#!/bin/bash
# Regenerate the checked-in unit Makefiles from one template per platform.
#
# The point is that a unit's Makefile is not hand-maintained: change the
# template here, run this, and every unit follows. What it must never do is
# invent a Makefile. Only directories that already have one are rewritten.
#
# That contract is deliberate. Most units have no Makefile and should not:
# Spectrum's 61 assembly units build through the capture harness, the AMOS
# track is not assembled at all, and a generator that walked the tree looking
# for source would have created dozens of files nobody asked for.
#
# BASIC is the one exception: for every unit-NN lesson page under a
# `basic/<module>/` track, this script derives the unit's program (the last
# `CodeFromFile` `.bas` src the page shows) from the sibling website checkout
# and writes a Makefile that builds exactly that listing with `build198x
# basic`, under its own filename, so the lesson's run strip runs the same
# bytes the page shows. Unlike the assembly platforms, a missing BASIC unit
# Makefile is created, not skipped — the website checkout names which units
# exist, so there is no risk of inventing one nobody asked for.
#
# A Makefile carrying targets this script does not emit is left alone and
# reported, so a unit that has grown its own verification or emulator wiring
# cannot be silently flattened back to the template.
#
# Usage: ./generate-makefiles.sh [--check]
#   --check  report what would change and exit non-zero, writing nothing.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEBSITE_DIR="${WEBSITE_DIR:-$SCRIPT_DIR/../website}"
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
        # A BASIC unit's directory may not exist yet — it is created fresh
        # from the website checkout, not discovered by an existing Makefile.
        mkdir -p "$(dirname "$path")"
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

# The comment a BASIC unit Makefile starts with: what it builds. An
# overridden unit passes its own note instead ($1), because it does not
# build the page's last listing.
basic_header() {
    if [ -n "$1" ]; then
        printf '%s\n' "$1"
    else
        cat <<'EOF'
# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
EOF
    fi
}

# A unit's Makefile builds the one listing its lesson page shows, under that
# listing's own filename (extension swapped for the machine's native output),
# so the run strip's program is byte-for-byte the program on the page. $1 is
# the listing's path relative to the unit directory; $2 is the output name.
spectrum_basic_makefile() {
    local rel_src="$1" out="$2"
    basic_header "${3:-}"
    cat <<EOF
BUILD198X ?= build198x

all: ${out}

${out}: ${rel_src}
	\$(BUILD198X) basic \$< --machine sinclair-zx-spectrum -o \$@

clean:
	rm -f ${out}

.PHONY: all clean
EOF
}

c64_basic_makefile() {
    local rel_src="$1" out="$2"
    basic_header "${3:-}"
    cat <<EOF
BUILD198X ?= build198x

all: ${out}

${out}: ${rel_src}
	\$(BUILD198X) basic \$< --machine commodore-c64 -o \$@

clean:
	rm -f ${out}

.PHONY: all clean
EOF
}

# Relative path from directory $1 to file $2, both repo-root-relative POSIX
# paths with no leading ./ — the bit of arithmetic a unit-NN Makefile needs
# to reach a listing that usually lives under a sibling teaching/ tree.
relpath() {
    local from="$1" to="$2"
    local -a from_parts to_parts
    IFS=/ read -r -a from_parts <<<"$from"
    IFS=/ read -r -a to_parts <<<"$to"
    local i=0
    while [ "$i" -lt "${#from_parts[@]}" ] && [ "$i" -lt "${#to_parts[@]}" ] \
        && [ "${from_parts[$i]}" = "${to_parts[$i]}" ]; do
        i=$((i + 1))
    done
    local up="" down="" j
    for ((j = i; j < ${#from_parts[@]}; j++)); do up="../$up"; done
    for ((j = i; j < ${#to_parts[@]}; j++)); do down="$down${to_parts[$j]}/"; done
    printf '%s' "${up}${down%/}"
}

# Step 1 (find each lesson's program) is: the last CodeFromFile .bas a unit's
# page shows. One listing breaks that rule on purpose: meet-basic/unit-04's
# last teaching step uses the illegal string variable name `name$` to show
# the ROM refusing it (Ruling R-name$, 2026-09-26), so `build198x basic`
# rightly fails its lint. basic-reference/unit-04 shows that same listing
# last, so its Makefile builds the page's earlier, legal step instead.
basic_source_override() {
    case "$1/$2/$3" in
        "sinclair-zx-spectrum/basic-reference/unit-04")
            echo "sinclair-zx-spectrum/basic/meet-basic/unit-04/steps/step-01.bas" ;;
        *) return 1 ;;
    esac
}

# The Makefile header for an overridden unit, saying what it builds instead.
basic_override_note() {
    case "$1/$2/$3" in
        "sinclair-zx-spectrum/basic-reference/unit-04")
            cat <<'EOF'
# Build the legal step-01 listing this lesson shows. The page's last listing,
# meet-basic's step-03, uses the illegal name `name$` on purpose to show the
# ROM refusing it, so it cannot build; the run strip runs step-01 instead.
EOF
            ;;
        *) return 1 ;;
    esac
}

# Walk every unit-NN lesson page under $1's basic/ track in the website
# checkout, and emit that unit's Makefile from $3 (one of the two template
# functions above). $2 is the native output extension (tap, prg).
generate_basic_makefiles() {
    local sysname="$1" ext="$2" tmpl="$3"
    local curriculum="$WEBSITE_DIR/src/content/curriculum/$sysname/basic"
    # The unit list comes from the lesson pages, so without them there is
    # nothing to check against: fail rather than report "current".
    [ -d "$curriculum" ] || {
        echo "error: $curriculum not found; set WEBSITE_DIR to a website checkout" >&2
        exit 1
    }
    while IFS= read -r mdxf; do
        local module unit_num unit_padded last_bas src_rel out_name unitdir override note=""
        module="$(basename "$(dirname "$mdxf")")"
        unit_num="$(sed -n 's/^unit:[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$mdxf" | head -1)"
        [ -n "$unit_num" ] || { echo "  $module/$(basename "$mdxf"): no unit: frontmatter, skipped"; continue; }
        unit_padded="$(printf 'unit-%02d' "$unit_num")"
        last_bas="$(grep -oE '<CodeFromFile[^>]*src="[^"]+\.bas"' "$mdxf" \
            | grep -oE 'src="[^"]+"' | sed -e 's/^src="//' -e 's/"$//' | tail -1)"
        [ -n "$last_bas" ] || { echo "  $module/$unit_padded: no .bas CodeFromFile, skipped"; continue; }
        if override="$(basic_source_override "$sysname" "$module" "$unit_padded")"; then
            last_bas="$override"
            note="$(basic_override_note "$sysname" "$module" "$unit_padded")"
        fi
        unitdir="$SCRIPT_DIR/$sysname/basic/$module/$unit_padded"
        src_rel="$(relpath "$sysname/basic/$module/$unit_padded" "$last_bas")"
        out_name="$(basename "$last_bas")"
        out_name="${out_name%.bas}.$ext"
        emit "$unitdir/Makefile" "$("$tmpl" "$src_rel" "$out_name" "$note")"
    done < <(find "$curriculum" -name 'unit-*.mdx' | sort)
}

while IFS= read -r mk; do
    dir="$(dirname "$mk")"
    case "${mk#"$SCRIPT_DIR"/}" in
        commodore-64/assembly/*)          emit "$mk" "$(c64_makefile "$dir")" ;;
        nintendo-entertainment-system/*) emit "$mk" "$(nes_makefile "$dir")" ;;
        commodore-amiga/*)               emit "$mk" "$(amiga_makefile "$dir")" ;;
        *) ;;   # Spectrum's only Makefile is a hand-written test harness.
    esac
done < <(find "$SCRIPT_DIR" -name Makefile -not -path "*/_*" | sort)

generate_basic_makefiles sinclair-zx-spectrum tap spectrum_basic_makefile
generate_basic_makefiles commodore-64 prg c64_basic_makefile

if [ "$CHECK" = 1 ]; then
    [ "$changed" = 0 ] && echo "Makefiles are current." || echo "$changed Makefile(s) out of date."
    [ "$skipped" -gt 0 ] && echo "$skipped left alone."
    exit $(( changed > 0 ))
fi
echo "Rewrote $written Makefile(s); $skipped left alone."
