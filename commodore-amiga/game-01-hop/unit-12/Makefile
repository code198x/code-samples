# Commodore Amiga Makefile
IMAGE = code198x/commodore-amiga
SRC   = hop.asm
EXE   = hop
ADF   = hop.adf
NAME  = Hop

.PHONY: all run clean

all: $(ADF)

$(EXE): $(SRC)
	docker run --rm -v "$(PWD)":/code -w /code $(IMAGE) \
		vasmm68k_mot -Fhunkexe -kick1hunks -nosym -o $(EXE) $(SRC)

$(ADF): $(EXE)
	docker run --rm -v "$(PWD)":/code -w /code $(IMAGE) bash -c "\
		echo '$(EXE)' > startup-sequence && \
		rm -f $(ADF) && \
		xdftool $(ADF) create + format '$(NAME)' ofs + boot install boot1x && \
		xdftool $(ADF) + makedir s + write startup-sequence s/startup-sequence && \
		xdftool $(ADF) + write $(EXE) + protect $(EXE) +e && \
		rm startup-sequence"

run: $(ADF)
	fs-uae --floppy_drive_0=$(ADF)

clean:
	rm -f $(EXE) $(ADF)
