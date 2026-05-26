.PHONY: all clean

all: halt_test.sna

%.sna: %.asm
	docker run --rm -v "$$(pwd)":/code -w /code \
		ghcr.io/code198x/sinclair-zx-spectrum:latest \
		pasmonext --sna $< $@

clean:
	rm -f *.sna
