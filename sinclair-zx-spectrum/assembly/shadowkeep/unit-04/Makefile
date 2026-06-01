.PHONY: all clean

STAGES := 01-the-keyboard-answers 02-a-first-step 03-the-thief-walks 04-a-measured-stride

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
