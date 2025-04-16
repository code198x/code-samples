all: hello.tap hello.bin

hello.tap: hello.asm
	pasmo --tapbas hello.asm hello.tap

hello.bin: hello.asm
	z80asm -o hello.bin hello.asm

clean:
	rm -f hello.tap hello.bin