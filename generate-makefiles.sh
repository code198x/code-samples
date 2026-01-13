#!/bin/bash
# Generate Makefiles for all unit directories

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

generate_c64_makefile() {
    local dir="$1"
    local asm_file=$(basename "$dir"/*.asm 2>/dev/null | head -1)
    local name="${asm_file%.asm}"

    if [ -z "$name" ] || [ "$name" = "*" ]; then
        echo "  Skipping $dir - no .asm file found"
        return
    fi

    cat > "$dir/Makefile" << EOF
# Commodore 64 Makefile
IMAGE = code198x/commodore-64
SRC   = ${name}.asm
OUT   = ${name}.prg

.PHONY: all run clean

all: \$(OUT)

\$(OUT): \$(SRC)
	docker run --rm -v "\$(PWD)":/code -w /code \$(IMAGE) \\
		acme -f cbm -o \$(OUT) \$(SRC)

run: \$(OUT)
	x64sc \$(OUT)

clean:
	rm -f \$(OUT)
EOF
    echo "  Created $dir/Makefile"
}

generate_spectrum_makefile() {
    local dir="$1"
    local asm_file=$(basename "$dir"/*.asm 2>/dev/null | head -1)
    local name="${asm_file%.asm}"

    if [ -z "$name" ] || [ "$name" = "*" ]; then
        echo "  Skipping $dir - no .asm file found"
        return
    fi

    cat > "$dir/Makefile" << EOF
# ZX Spectrum Makefile
IMAGE = code198x/sinclair-zx-spectrum
SRC   = ${name}.asm
OUT   = ${name}.tap

.PHONY: all run clean

all: \$(OUT)

\$(OUT): \$(SRC)
	docker run --rm -v "\$(PWD)":/code -w /code \$(IMAGE) \\
		pasmonext --tapbas \$(SRC) \$(OUT)

run: \$(OUT)
	fuse \$(OUT)

clean:
	rm -f \$(OUT)
EOF
    echo "  Created $dir/Makefile"
}

generate_amiga_makefile() {
    local dir="$1"
    local asm_file=$(basename "$dir"/*.asm 2>/dev/null | head -1)
    local name="${asm_file%.asm}"

    if [ -z "$name" ] || [ "$name" = "*" ]; then
        echo "  Skipping $dir - no .asm file found"
        return
    fi

    # Capitalise first letter for disk name
    local disk_name="$(echo "${name:0:1}" | tr '[:lower:]' '[:upper:]')${name:1}"

    cat > "$dir/Makefile" << EOF
# Commodore Amiga Makefile
IMAGE = code198x/commodore-amiga
SRC   = ${name}.asm
EXE   = ${name}
ADF   = ${name}.adf
NAME  = ${disk_name}

.PHONY: all run clean

all: \$(ADF)

\$(EXE): \$(SRC)
	docker run --rm -v "\$(PWD)":/code -w /code \$(IMAGE) \\
		vasmm68k_mot -Fhunkexe -kick1hunks -nosym -o \$(EXE) \$(SRC)

\$(ADF): \$(EXE)
	docker run --rm -v "\$(PWD)":/code -w /code \$(IMAGE) bash -c "\\
		echo '\$(EXE)' > startup-sequence && \\
		rm -f \$(ADF) && \\
		xdftool \$(ADF) create + format '\$(NAME)' ofs + boot install boot1x && \\
		xdftool \$(ADF) + makedir s + write startup-sequence s/startup-sequence && \\
		xdftool \$(ADF) + write \$(EXE) + protect \$(EXE) +e && \\
		rm startup-sequence"

run: \$(ADF)
	fs-uae --floppy_drive_0=\$(ADF)

clean:
	rm -f \$(EXE) \$(ADF)
EOF
    echo "  Created $dir/Makefile"
}

generate_nes_makefile() {
    local dir="$1"
    local asm_file=$(basename "$dir"/*.asm 2>/dev/null | head -1)
    local name="${asm_file%.asm}"

    if [ -z "$name" ] || [ "$name" = "*" ]; then
        echo "  Skipping $dir - no .asm file found"
        return
    fi

    cat > "$dir/Makefile" << EOF
# NES Makefile
IMAGE = code198x/nintendo-entertainment-system
SRC   = ${name}.asm
CFG   = nes.cfg
OBJ   = ${name}.o
ROM   = ${name}.nes

.PHONY: all run clean

all: \$(ROM)

\$(OBJ): \$(SRC)
	docker run --rm -v "\$(PWD)":/code -w /code \$(IMAGE) \\
		ca65 \$(SRC) -o \$(OBJ)

\$(ROM): \$(OBJ) \$(CFG)
	docker run --rm -v "\$(PWD)":/code -w /code \$(IMAGE) \\
		ld65 -C \$(CFG) \$(OBJ) -o \$(ROM)

run: \$(ROM)
	fceux \$(ROM)

clean:
	rm -f \$(OBJ) \$(ROM)
EOF
    echo "  Created $dir/Makefile"
}

echo "Generating Makefiles for code-samples..."

# C64
echo "Commodore 64:"
for dir in "$SCRIPT_DIR"/commodore-64/*/unit-*/; do
    [ -d "$dir" ] && generate_c64_makefile "$dir"
done

# ZX Spectrum
echo "ZX Spectrum:"
for dir in "$SCRIPT_DIR"/sinclair-zx-spectrum/*/unit-*/; do
    [ -d "$dir" ] && generate_spectrum_makefile "$dir"
done

# Amiga
echo "Commodore Amiga:"
for dir in "$SCRIPT_DIR"/commodore-amiga/*/unit-*/; do
    [ -d "$dir" ] && generate_amiga_makefile "$dir"
done

# NES
echo "NES:"
for dir in "$SCRIPT_DIR"/nintendo-entertainment-system/*/unit-*/; do
    [ -d "$dir" ] && generate_nes_makefile "$dir"
done

echo "Done!"
