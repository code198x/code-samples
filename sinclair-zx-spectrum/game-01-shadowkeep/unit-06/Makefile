.PHONY: all clean

STAGES := 01-gold-falls 02-the-way-out 03-victory 04-locked-until-cleared

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
