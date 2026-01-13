# ZX Spectrum Makefile
IMAGE = code198x/sinclair-zx-spectrum
SRC   = inkwar.asm
OUT   = inkwar.tap

.PHONY: all run clean

all: $(OUT)

$(OUT): $(SRC)
	docker run --rm -v "$(PWD)":/code -w /code $(IMAGE) \
		pasmonext --tapbas $(SRC) $(OUT)

run: $(OUT)
	fuse $(OUT)

clean:
	rm -f $(OUT)
