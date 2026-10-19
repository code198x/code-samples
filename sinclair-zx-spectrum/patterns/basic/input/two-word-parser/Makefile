BUILD198X ?= build198x
PYTHON ?= python3
all: build/demo.tap
build/program.bas: demo.bas parser.bas vocabulary.bas
	mkdir -p build
	$(PYTHON) -c 'from pathlib import Path; lines=[line for name in ["demo.bas","parser.bas","vocabulary.bas"] for line in Path(name).read_text().splitlines() if line.strip()]; lines.sort(key=lambda line:int(line.split()[0])); Path("$@").write_text("\n".join(f"{int(line.split()[0]):4d} {line.split(maxsplit=1)[1]}" for line in lines)+"\n")'
build/demo.tap: build/program.bas
	$(BUILD198X) basic build/program.bas -o $@ --machine sinclair-zx-spectrum --name "PARSER"
.PHONY: all
