; A byte in our program becomes eight pixels at the top left.
; The remaining screen still belongs to the ROM loader.
 org 32768
start:
 ld a,0
 out ($FE),a
 ld a,71
 ld ($5800),a
 ld a,(pattern)
 ld ($4000),a
hold:
 jr hold
pattern:
 defb %10101010
 end start
