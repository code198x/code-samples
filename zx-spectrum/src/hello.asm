; hello.asm - fill top-left part of the screen with ASCII 'A'
ORG 32768         ; Start of our program in memory

LD HL, 16384      ; Start of screen memory
LD B, 32          ; Number of lines
OuterLoop:
    LD C, 32      ; Characters per line
InnerLoop:
    LD (HL), 65   ; ASCII 'A'
    INC HL
    DEC C
    JP NZ, InnerLoop
    DEC B
    JP NZ, OuterLoop

JP $