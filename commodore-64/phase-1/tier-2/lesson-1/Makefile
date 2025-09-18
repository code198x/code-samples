# Makefile for Commodore 64 Assembly
# Lesson 33: Decision Making with Branches

PRG = program.prg
ASM = main.asm
EMULATOR = x64sc

.PHONY: all clean run docker-build

all: $(PRG)

$(PRG): $(ASM)
	acme -o $(PRG) $(ASM)

# Build using Docker (if ACME not installed locally)
docker-build: $(ASM)
	docker run --rm -v $(PWD):/workspace code198x/acme acme -o $(PRG) $(ASM)

run: $(PRG)
	$(EMULATOR) $(PRG)

clean:
	rm -f $(PRG) *.o *.lst

# Verification target for CI
verify: $(ASM)
	@echo "Verifying assembly code..."
	@if command -v acme >/dev/null 2>&1; then \
		acme -o test.prg $(ASM) && rm -f test.prg && echo "✓ Assembly verified"; \
	else \
		echo "⚠ ACME not found, trying Docker..."; \
		docker run --rm -v $(PWD):/workspace code198x/acme acme -o test.prg $(ASM) && rm -f test.prg && echo "✓ Assembly verified"; \
	fi

help:
	@echo "Available targets:"
	@echo "  make          - Build the PRG file"
	@echo "  make run      - Build and run in VICE"
	@echo "  make docker-build - Build using Docker"
	@echo "  make verify   - Verify assembly syntax"
	@echo "  make clean    - Remove build artifacts"