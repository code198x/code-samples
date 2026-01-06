;──────────────────────────────────────────────────────────────
; HOP
; A Frogger-style game for the Commodore Amiga
; Unit 1: The Lanes
;──────────────────────────────────────────────────────────────
; Minimal copper bar display showing game zones
;──────────────────────────────────────────────────────────────

CUSTOM          equ $dff000

; Exec
ExecBase        equ 4
OldOpenLibrary  equ -408
CloseLibrary    equ -414

; Graphics library
LoadView        equ -222
WaitTOF         equ -270

;──────────────────────────────────────────────────────────────
; Code section (can be in any RAM)
;──────────────────────────────────────────────────────────────
            section code,code

start:
            move.l  ExecBase,a6

            ; Open graphics.library
            lea     gfxname(pc),a1
            jsr     OldOpenLibrary(a6)
            move.l  d0,gfxbase
            beq     .exit

            ; Save current view and copper
            move.l  d0,a6
            move.l  34(a6),oldview          ; gb_ActiView
            move.l  38(a6),oldcopper        ; gb_copinit

            ; Clear view (blank display)
            sub.l   a1,a1
            jsr     LoadView(a6)
            jsr     WaitTOF(a6)
            jsr     WaitTOF(a6)

            ; Now take over hardware
            lea     CUSTOM,a5

            ; Disable interrupts
            move.w  #$7fff,$9a(a5)          ; INTENA - all off
            move.w  #$7fff,$9c(a5)          ; INTREQ - clear all

            ; Install our copper list (in chip RAM section)
            lea     copperlist,a0
            move.l  a0,$80(a5)              ; COP1LC
            move.w  d0,$88(a5)              ; COPJMP1 - strobe

            ; Enable copper DMA
            move.w  #$8280,$96(a5)          ; DMACON - copper + master

.mainloop:
            ; Wait for vertical blank
            move.l  #$1ff00,d1
.vbwait:
            move.l  4(a5),d0                ; VPOSR/VHPOSR
            and.l   d1,d0
            cmp.l   #$00000,d0              ; Line 0
            bne.s   .vbwait

            ; Check left mouse button
            btst    #6,$bfe001
            bne.s   .mainloop

            ; Restore system
            move.l  gfxbase(pc),a6
            move.l  oldcopper(pc),$80+CUSTOM    ; Restore copper
            move.w  d0,$88+CUSTOM               ; COPJMP1

            move.l  oldview(pc),a1
            jsr     LoadView(a6)
            jsr     WaitTOF(a6)
            jsr     WaitTOF(a6)

            ; Re-enable interrupts
            move.w  #$c000,$9a+CUSTOM       ; INTENA master on

            ; Close graphics library
            move.l  a6,a1
            move.l  ExecBase,a6
            jsr     CloseLibrary(a6)

.exit:
            moveq   #0,d0
            rts

;──────────────────────────────────────────────────────────────
; Variables (in code section for PC-relative access)
;──────────────────────────────────────────────────────────────
gfxname:    dc.b    "graphics.library",0
            even

oldview:    dc.l    0
oldcopper:  dc.l    0
gfxbase:    dc.l    0

;──────────────────────────────────────────────────────────────
; Copper list - MUST be in chip RAM
;──────────────────────────────────────────────────────────────
            section chipdata,data_c

copperlist:
            ; Background color changes per scanline
            ; Representing Hop zones: grass, road, water, goal

            ; Top border - black
            dc.w    $0180,$0000             ; COLOR00 = black

            ; Wait for display start, then green (top grass/safe zone)
            dc.w    $2c07,$fffe             ; Wait line $2c
            dc.w    $0180,$0070             ; COLOR00 = dark green

            dc.w    $4007,$fffe             ; Wait line $40
            dc.w    $0180,$0080             ; COLOR00 = green

            ; Road zone - grey stripes
            dc.w    $5007,$fffe
            dc.w    $0180,$0444             ; Dark grey (road)

            dc.w    $5c07,$fffe
            dc.w    $0180,$0666             ; Light grey (lane marker)

            dc.w    $6007,$fffe
            dc.w    $0180,$0444             ; Dark grey

            dc.w    $6c07,$fffe
            dc.w    $0180,$0666             ; Light grey

            dc.w    $7007,$fffe
            dc.w    $0180,$0444             ; Dark grey

            ; Median - green safe zone
            dc.w    $7807,$fffe
            dc.w    $0180,$0080             ; Green

            ; More road
            dc.w    $8007,$fffe
            dc.w    $0180,$0444             ; Dark grey

            dc.w    $8c07,$fffe
            dc.w    $0180,$0666             ; Light grey

            dc.w    $9007,$fffe
            dc.w    $0180,$0444             ; Dark grey

            dc.w    $9c07,$fffe
            dc.w    $0180,$0666             ; Light grey

            dc.w    $a007,$fffe
            dc.w    $0180,$0444             ; Dark grey

            ; Water zone - blue stripes
            dc.w    $a807,$fffe
            dc.w    $0180,$0048             ; Dark blue (water)

            dc.w    $b007,$fffe
            dc.w    $0180,$006b             ; Medium blue

            dc.w    $b807,$fffe
            dc.w    $0180,$0048             ; Dark blue

            dc.w    $c007,$fffe
            dc.w    $0180,$006b             ; Medium blue

            dc.w    $c807,$fffe
            dc.w    $0180,$0048             ; Dark blue

            dc.w    $d007,$fffe
            dc.w    $0180,$006b             ; Medium blue

            ; Home/goal zone - green
            dc.w    $d807,$fffe
            dc.w    $0180,$0080             ; Green

            dc.w    $e807,$fffe
            dc.w    $0180,$0070             ; Darker green

            ; Bottom border
            dc.w    $f007,$fffe
            dc.w    $0180,$0000             ; Black

            ; End copper list
            dc.w    $ffff,$fffe
