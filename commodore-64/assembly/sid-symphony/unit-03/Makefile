# Commodore 64 Makefile
IMAGE = code198x/commodore-64
SRC   = symphony.asm
OUT   = symphony.prg

.PHONY: all run clean

all: $(OUT)

$(OUT): $(SRC)
	docker run --rm -v "$(PWD)":/code -w /code $(IMAGE) \
		acme -f cbm -o $(OUT) $(SRC)

run: $(OUT)
	x64sc $(OUT)

clean:
	rm -f $(OUT)
