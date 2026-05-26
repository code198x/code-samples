.PHONY: all clean

STAGES := 01-a-title-card 02-title-with-music 03-title-to-game 04-the-keep-stands

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
