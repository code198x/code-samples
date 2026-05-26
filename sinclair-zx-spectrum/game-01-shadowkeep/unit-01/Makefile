.PHONY: all clean

STAGES := 01-the-dark 02-first-torch 03-two-torches 04-flickering

all: $(addsuffix .tap,$(STAGES)) $(addsuffix .sna,$(STAGES))

%.tap: %.asm
	docker run --rm -v "$$(pwd)":/code -w /code \
		ghcr.io/code198x/sinclair-zx-spectrum:latest \
		pasmonext --tapbas $< $@

%.sna: %.asm
	docker run --rm -v "$$(pwd)":/code -w /code \
		ghcr.io/code198x/sinclair-zx-spectrum:latest \
		pasmonext --sna $< $@

clean:
	rm -f *.tap *.sna
