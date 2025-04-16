all: hello.tap hello.bin

hello.tap: src/hello.asm
	sjasmplus src/hello.asm

hello.bin: src/hello.asm
	sjasmplus --raw=hello.bin src/hello.asm

clean:
	rm -f hello.tap hello.bin