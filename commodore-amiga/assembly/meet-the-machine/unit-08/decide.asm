;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 8: Test, Then Branch
;
; There is no IF. You COMPARE two values - which sets the flags - then BRANCH on
; a flag. The YOUR CODE block decides which colour ends up in the slot.
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
            move.w  #5,d0               ; the value we'll ask about
            cmp.w   #5,d0               ; compare it with 5 - sets the flags
            beq     .equal              ; branch if equal
            move.w  #$0f00,colourval    ; not equal: red
            bra     .show
.equal:
            move.w  #$00f0,colourval    ; equal: green
.show:
            ; ------------------------------------------------- YOUR CODE END

forever:
            bra.s   forever

copperlist:
            dc.w    BPLCON0,$0200
            dc.w    COLOR00
colourval:
            dc.w    $0000
            dc.w    $ffff,$fffe
