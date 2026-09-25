# Build case 1 of this unit's investigation, the faulty program the lesson's debugger
# starts from. Its source lives in opening/. Case 2 (debug-trail.asm) is left
# unbuilt: the run strip runs the last tape in the folder, and case 2 sorts last.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: debug-branch.tap

debug-branch.tap: ../opening/debug-branch.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f debug-branch.tap

.PHONY: all clean
