# NES Makefile
IMAGE = code198x/nintendo-entertainment-system
SRC   = nexus.asm
CFG   = nes.cfg
OBJ   = nexus.o
ROM   = nexus.nes

.PHONY: all run clean

all: $(ROM)

$(OBJ): $(SRC)
	docker run --rm -v "$(PWD)":/code -w /code $(IMAGE) \
		ca65 $(SRC) -o $(OBJ)

$(ROM): $(OBJ) $(CFG)
	docker run --rm -v "$(PWD)":/code -w /code $(IMAGE) \
		ld65 -C $(CFG) $(OBJ) -o $(ROM)

run: $(ROM)
	fceux $(ROM)

clean:
	rm -f $(OBJ) $(ROM)
