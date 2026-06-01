# NES Makefile
IMAGE = code198x/nintendo-entertainment-system
SRC   = dash.asm
CFG   = nes.cfg
OBJ   = dash.o
ROM   = dash.nes

.PHONY: all clean

all: $(ROM)

$(OBJ): $(SRC)
	docker run --rm -v "$(PWD)":/code -w /code $(IMAGE) \
		ca65 $(SRC) -o $(OBJ)

$(ROM): $(OBJ) $(CFG)
	docker run --rm -v "$(PWD)":/code -w /code $(IMAGE) \
		ld65 -C $(CFG) $(OBJ) -o $(ROM)

clean:
	rm -f $(OBJ) $(ROM)
