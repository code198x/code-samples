BUILD198X ?= build198x
PYTHON ?= python3
all: build/demo.prg
build/program.bas: caller.bas parser.bas vocabulary.bas
	mkdir -p build
	$(PYTHON) -c 'from pathlib import Path; lines=[line for name in ["caller.bas","parser.bas","vocabulary.bas"] for line in Path(name).read_text().splitlines() if line.strip()]; lines.sort(key=lambda line:int(line.split()[0])); Path("$@").write_text("\n".join(lines)+"\n")'
build/demo.prg: build/program.bas
	$(BUILD198X) basic build/program.bas -o $@ --machine commodore-c64 --name PARSER
.PHONY: all
