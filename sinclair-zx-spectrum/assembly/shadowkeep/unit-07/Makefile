.PHONY: all clean

STAGES := 01-one-note 02-two-notes 03-a-melody 04-the-theme

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
