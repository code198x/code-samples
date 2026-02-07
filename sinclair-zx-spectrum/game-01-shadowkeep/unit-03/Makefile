.PHONY: all clean

all: shadowkeep.tap shadowkeep.sna

shadowkeep.tap: shadowkeep.asm
	docker run --rm -v "$$(pwd)":/code -w /code \
		ghcr.io/code198x/sinclair-zx-spectrum:latest \
		pasmonext --tapbas shadowkeep.asm shadowkeep.tap

shadowkeep.sna: shadowkeep.asm
	docker run --rm -v "$$(pwd)":/code -w /code \
		ghcr.io/code198x/sinclair-zx-spectrum:latest \
		pasmonext --sna shadowkeep.asm shadowkeep.sna

clean:
	rm -f shadowkeep.tap shadowkeep.sna
