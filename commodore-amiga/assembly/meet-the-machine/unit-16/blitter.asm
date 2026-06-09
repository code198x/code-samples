;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 16: The Blitter Moves It
;
; The Blitter is a chip that shifts blocks of memory - graphics - far faster
; than the CPU. Here the CPU draws one block; the Blitter copies it somewhere
; else in a single operation. Two blocks appear; the CPU only ever drew one.
; (Display set-up is the same one-bitplane harness from Unit 6.)
;──────────────────────────────────────────────────────────────

CUSTOM      equ $dff000
DMACONR     equ $002            ; DMA status (read) - bit 14 = Blitter busy
DMACON      equ $096
INTENA      equ $09a
INTREQ      equ $09c
COP1LC      equ $080
COPJMP1     equ $088
DIWSTRT     equ $08e
DIWSTOP     equ $090
DDFSTRT     equ $092
DDFSTOP     equ $094
BLTCON0     equ $040
BLTCON1     equ $042
BLTAFWM     equ $044
BLTALWM     equ $046
BLTAPTH     equ $050
BLTDPTH     equ $054
BLTAMOD     equ $064
BLTDMOD     equ $066
BLTSIZE     equ $058
BPLCON0     equ $100
BPL1MOD     equ $108
BPL1PTH     equ $0e0
BPL1PTL     equ $0e2
COLOR00     equ $180
COLOR01     equ $182

ROWBYTES    equ 40                  ; 320 pixels / 8 = 40 bytes per row
BPHEIGHT    equ 256
BPSIZE      equ ROWBYTES*BPHEIGHT
BLTW        equ 2                   ; blit width in words (32 pixels)
BLTH        equ 24                  ; blit height in rows
DESTOFF     equ 80*ROWBYTES+8       ; dest: 80 rows down, 64 pixels across

            section code,code_c

start:
            lea     CUSTOM,a5
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)

            ; --- clear the bitplane to all 0 ---
            lea     bitplane,a0
            move.w  #(BPSIZE/4)-1,d0
.clr:       clr.l   (a0)+
            dbra    d0,.clr

            ; --- CPU draws ONE block, top-left: 32 wide, 24 rows ---
            lea     bitplane,a0
            move.w  #BLTH-1,d1
.row:       move.l  #$ffffffff,(a0)
            lea     ROWBYTES(a0),a0
            dbra    d1,.row

            ; --- point the display at the bitplane (patch the Copper) ---
            lea     bitplane,a0
            move.l  a0,d0
            swap    d0
            move.w  d0,bplhi
            swap    d0
            move.w  d0,bpllo

            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)
            move.w  #$83c0,DMACON(a5)   ; DMA on: master + bitplane + Copper + Blitter

            ; ----------------------------------------------- YOUR CODE START
            ; --- the Blitter copies the block to a new spot ---
.waitblit:  btst    #6,DMACONR(a5)      ; wait until the Blitter is idle
            bne.s   .waitblit

            move.w  #$ffff,BLTAFWM(a5)  ; no masking of the first/last word
            move.w  #$ffff,BLTALWM(a5)
            move.w  #$09f0,BLTCON0(a5)  ; use A and D; D = A (a straight copy)
            move.w  #$0000,BLTCON1(a5)
            move.w  #ROWBYTES-BLTW*2,BLTAMOD(a5)   ; skip the rest of each source row
            move.w  #ROWBYTES-BLTW*2,BLTDMOD(a5)   ; ...and each dest row

            lea     bitplane,a0
            move.l  a0,BLTAPTH(a5)      ; source = the block the CPU drew
            lea     bitplane+DESTOFF,a0
            move.l  a0,BLTDPTH(a5)      ; dest = down and across

            move.w  #(BLTH<<6)!BLTW,BLTSIZE(a5)    ; height + width - this starts the blit
            ; ------------------------------------------------- YOUR CODE END

forever:
            bra.s   forever

;──────────────────────────────────────────────────────────────
; Copper list: one-bitplane 320x256 display.
;──────────────────────────────────────────────────────────────
copperlist:
            dc.w    DIWSTRT,$2c81
            dc.w    DIWSTOP,$2cc1
            dc.w    DDFSTRT,$0038
            dc.w    DDFSTOP,$00d0
            dc.w    BPLCON0,$1200
            dc.w    BPL1MOD,$0000
            dc.w    BPL1PTH
bplhi:      dc.w    $0000
            dc.w    BPL1PTL
bpllo:      dc.w    $0000
            dc.w    COLOR00,$0000       ; background black
            dc.w    COLOR01,$0ff0       ; lit pixels yellow
            dc.w    $ffff,$fffe

            section bss,bss_c
bitplane:   ds.b    BPSIZE
