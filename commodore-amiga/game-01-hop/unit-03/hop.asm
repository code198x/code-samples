;──────────────────────────────────────────────────────────────
; HOP - Unit 3 sample (Movement + sprite)
; Builds on Unit 2 sprite: adds a simple movement loop for the frog.
;──────────────────────────────────────────────────────────────

CUSTOM          equ $dff000
ExecBase        equ 4
OldOpenLibrary  equ -408
CloseLibrary    equ -414
LoadView        equ -222
WaitTOF         equ -270

            section code,code
start:
            move.l  ExecBase,a6
            lea     gfxname,a1
            jsr     OldOpenLibrary(a6)
            move.l  d0,gfxbase
            beq     .exit

            move.l  d0,a6
            move.l  34(a6),oldview
            move.l  38(a6),oldcopper

            sub.l   a1,a1
            jsr     LoadView(a6)
            jsr     WaitTOF(a6)
            jsr     WaitTOF(a6)

            lea     CUSTOM,a5
            move.w  #$7fff,$9a(a5)
            move.w  #$7fff,$9c(a5)

            lea     copperlist,a0
            move.l  a0,$80(a5)
            move.w  d0,$88(a5)

            move.w  #$83a0,$96(a5)

            move.w  #160,frog_x
            move.w  #220,frog_y
            lea     bitplane,a0
            move.l  a0,$e0(a5)
            lea     sprite0,a0
            move.l  a0,$120(a5)
.clear:
            bsr     clear_bpl

.mainloop:
            bsr     wait_vb
            bsr     handle_input
            bsr     draw_frog_sprite
            bra     .mainloop

.exit:      rts

wait_vb:
            move.l  #$1ff00,d1
.vbwait:
            move.l  4(a5),d0
            and.l   d1,d0
            cmp.l   #$00000,d0
            bne.s   .vbwait
            rts

handle_input:
            ; placeholder: slow move left/right
            addq.w  #1,counter
            move.w  counter,d0
            andi.w  #$0010,d0
            beq.s   .mv_left
            addq.w  #1,frog_x
            bra.s   .done
.mv_left:
            subq.w  #1,frog_x
.done:      rts

clear_bpl:
            lea     bitplane,a0
            move.l  #((320*256)/8),d0
            moveq   #0,d1
.clr_lp:
            move.b  d1,(a0)+
            subq.l  #1,d0
            bne.s   .clr_lp
            rts

draw_frog_sprite:
            lea     CUSTOM,a5
            move.w  frog_x,d0
            move.w  frog_y,d1
            andi.w  #$00ff,d0
            andi.w  #$00ff,d1
            move.w  d1,d2
            lsl.w   #8,d2
            or.w    d0,d2
            move.w  d2,$140(a5)
            move.w  #0,$142(a5)
            rts

counter:    dc.w 0

            section chipdata,data_c
copperlist:
            dc.w $0180,$0000
            dc.w $2c07,$fffe
            dc.w $0180,$0070
            dc.w $4007,$fffe
            dc.w $0180,$0080
            dc.w $5007,$fffe
            dc.w $0180,$0444
            dc.w $5c07,$fffe
            dc.w $0180,$0666
            dc.w $6007,$fffe
            dc.w $0180,$0444
            dc.w $6c07,$fffe
            dc.w $0180,$0666
            dc.w $7007,$fffe
            dc.w $0180,$0444
            dc.w $7807,$fffe
            dc.w $0180,$0080
            dc.w $8007,$fffe
            dc.w $0180,$0444
            dc.w $8c07,$fffe
            dc.w $0180,$0666
            dc.w $9007,$fffe
            dc.w $0180,$0444
            dc.w $9c07,$fffe
            dc.w $0180,$0666
            dc.w $a007,$fffe
            dc.w $0180,$0444
            dc.w $a807,$fffe
            dc.w $0180,$0048
            dc.w $b007,$fffe
            dc.w $0180,$006b
            dc.w $b807,$fffe
            dc.w $0180,$0048
            dc.w $c007,$fffe
            dc.w $0180,$006b
            dc.w $c807,$fffe
            dc.w $0180,$0048
            dc.w $d007,$fffe
            dc.w $0180,$006b
            dc.w $d807,$fffe
            dc.w $0180,$0080
            dc.w $e807,$fffe
            dc.w $0180,$0070
            dc.w $f007,$fffe
            dc.w $0180,$0000
            dc.w $ffff,$fffe

            section data,data
frog_x:     dc.w 0
frog_y:     dc.w 0
bitplane:   ds.b 10240
sprite0:
            dc.w $0000,$0000,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe
            dc.w $7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$0000,$0000
            dc.w $7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe
            dc.w $7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$0000,$0000
            dc.w 0,0
gfxname:    dc.b "graphics.library",0
oldview:    dc.l 0
oldcopper:  dc.l 0
gfxbase:    dc.l 0
