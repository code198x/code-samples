ASM198X ?= asm198x
BUILD198X ?= build198x
# Keep the publishing pipeline's pinned CLI; the standalone CLI uses an empty subcommand.
ADF_SUBCOMMAND ?= $(if $(filter build198x-adf,$(notdir $(BUILD198X))),,adf)
.PHONY: all clean
all: build/demo.adf
build/demo: demo.asm clip.inc draw.inc shapes.inc ../../framework/game-loop/frame.inc
	mkdir -p build
	$(ASM198X) --dialect vasm --exe --sym=build/demo.sym demo.asm -o $@
build/demo.adf: build/demo
	$(BUILD198X) $(ADF_SUBCOMMAND) build/demo -o $@ --name demo
clean:
	rm -rf build
