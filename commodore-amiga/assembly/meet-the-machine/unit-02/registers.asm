;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 2: MOVE Is the Verb
;
; Same harness as Unit 1 — but now the colour the Copper shows is one the CPU
; writes into the list. The YOUR CODE block uses MOVE, the 68000's workhorse,
; to put a value into a register and then into memory. Whatever colour you
; leave in the Copper's colour slot is what fills the screen.
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
            move.w  #$00f0,d0           ; immediate -> register: green into d0
            move.w  d0,colourval        ; register -> memory: d0 into the slot
            ; ------------------------------------------------- YOUR CODE END

forever:
            bra.s   forever

;──────────────────────────────────────────────────────────────
; The Copper list. Its colour word is a labelled slot the CPU fills in.
;──────────────────────────────────────────────────────────────
copperlist:
            dc.w    BPLCON0,$0200       ; 0 bitplanes - show only the background
            dc.w    COLOR00             ; the register the Copper writes...
colourval:
            dc.w    $0000               ; ...with this value (the CPU sets it)
            dc.w    $ffff,$fffe         ; end of the Copper list
