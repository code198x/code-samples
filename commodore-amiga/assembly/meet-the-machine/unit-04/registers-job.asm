;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 4: A Register for Every Job
;
; The 68000 has sixteen registers: eight DATA registers (d0-d7) for values and
; maths, and eight ADDRESS registers (a0-a7) for addresses. Far more room than
; an 8-bit chip's two or three. Here a colour rides from one data register to
; another before it reaches the screen.
;──────────────────────────────────────────────────────────────

CUSTOM      equ $dff000
DMACON      equ $096
INTENA      equ $09a
INTREQ      equ $09c
COP1LC      equ $080
COPJMP1     equ $088
BPLCON0     equ $100
COLOR00     equ $180

            section code,code_c

start:
            lea     CUSTOM,a5
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)
            move.w  #$8280,DMACON(a5)

            ; ----------------------------------------------- YOUR CODE START
            move.w  #$0a0f,d0           ; a magenta into data register d0
            move.w  d0,d3               ; d0 -> d3 (any data register will do)
            move.w  d3,colourval        ; d3 -> the Copper's colour slot
            ; ------------------------------------------------- YOUR CODE END

forever:
            bra.s   forever

copperlist:
            dc.w    BPLCON0,$0200
            dc.w    COLOR00
colourval:
            dc.w    $0000
            dc.w    $ffff,$fffe
