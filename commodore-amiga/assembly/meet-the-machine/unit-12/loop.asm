;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 12: The Counted Loop
;
; DBRA is the 68000's count-and-loop instruction: it decrements a register and
; branches back until the register runs past zero. Here a loop builds a colour
; by adding a step on every pass.
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
            moveq   #0,d1               ; the colour, built up from zero
            move.w  #15-1,d0            ; loop 15 times (dbra runs count+1 passes)
.loop:
            add.w   #$0101,d1           ; add a step to the colour each pass
            dbra    d0,.loop            ; decrement d0, branch back until it's -1
            move.w  d1,colourval        ; 15 * $0101 = $0f0f -> magenta
            ; ------------------------------------------------- YOUR CODE END

forever:
            bra.s   forever

copperlist:
            dc.w    BPLCON0,$0200
            dc.w    COLOR00
colourval:
            dc.w    $0000
            dc.w    $ffff,$fffe
