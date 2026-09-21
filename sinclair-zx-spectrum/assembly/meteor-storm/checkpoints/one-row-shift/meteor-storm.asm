; Bit-shift microscope: inspect the two rows at screen y=64.
 org 32768
start:
 di
 ld sp,$FCF0
 call clear
 ; Original row at column 12, pixel y=64.
 ld a,%10000001
 ld ($480C),a
 ; Shift right once, carrying the lost bit into the next byte.
 ; RR starts with the carry from SRL: $81,0 becomes $40,$80.
 ld a,%10000001
 ld b,0
 srl a
 rr b
 ld ($490C),a
 ld a,b
 ld ($490D),a
hold:
 jr hold
clear:
 xor a
 out ($FE),a
 ld hl,$4000
 ld de,$4001
 ld bc,6143
 ld (hl),a
 ldir
 ld hl,$5800
 ld de,$5801
 ld bc,767
 ld (hl),$47
 ldir
 ret
 end start
