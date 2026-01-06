;──────────────────────────────────────────────────────────────
; HOP - Unit 5 sample (Traffic animation, visible)
; Builds on Unit 4: blitted traffic BOBs, frog sprite, single bitplane.
;──────────────────────────────────────────────────────────────

CUSTOM          equ $dff000
ExecBase        equ 4
OldOpenLibrary  equ -408
CloseLibrary    equ -414
LoadView        equ -222
WaitTOF         equ -270

BLTCON0         equ $040
BLTCON1         equ $042
BLTAFWM         equ $044
BLTALWM         equ $046
BLTAPTH         equ $050
BLTAPTL         equ $052
BLTBPTH         equ $054
BLTBPTL         equ $056
BLTCPTH         equ $058
BLTCPTL         equ $05a
BLTDPTH         equ $05c
BLTDPTL         equ $05e
BLTSIZE         equ $058
BLTAMOD         equ $064
BLTBMOD         equ $062
BLTCMOD         equ $060
BLTDMOD         equ $060

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

            lea     bitplane,a0
            move.l  a0,$e0(a5)
            move.w  #0,$e4(a5)
            move.w  #0,$e8(a5)
            move.w  #0,$ec(a5)
            move.w  #0,$f0(a5)
            move.w  #0,$f4(a5)

            lea     copperlist,a0
            move.l  a0,$80(a5)
            move.w  d0,$88(a5)

            move.w  #$83a0,$96(a5)

            bsr     clear_bpl
            bsr     init_state

.mainloop:
            bsr     wait_vb
            bsr     update_traffic
            bsr     draw_scene
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

clear_bpl:
            lea     bitplane,a0
            move.l  #((320*256)/8),d0
            moveq   #0,d1
.clr_lp:
            move.b  d1,(a0)+
            subq.l  #1,d0
            bne.s   .clr_lp
            rts

init_state:
            move.w  #160,frog_x
            move.w  #220,frog_y
            lea     sprite0,a0
            move.l  a0,$120(a5)

            move.b  #3,traffic_count
            lea     traffic_x,a0
            move.w  #40,(a0)+
            move.w  #140,(a0)+
            move.w  #260,(a0)+
            lea     traffic_y,a0
            move.w  #120,(a0)+
            move.w  #136,(a0)+
            move.w  #152,(a0)+
            lea     traffic_speed,a0
            move.w  #2,(a0)+
            move.w  #-3,(a0)+
            move.w  #2,(a0)+
            rts

update_traffic:
            lea     traffic_x,a0
            lea     traffic_speed,a1
            moveq   #0,d7
            move.b  traffic_count,d7
            subq.b  #1,d7
.loop:
            move.w  (a0),d0
            add.w   (a1),d0
            move.w  d0,(a0)
            cmp.w   #320,d0
            blt.s   .chk_left
            move.w  #-32,(a0)
            bra.s   .next
.chk_left:
            cmp.w   #-48,d0
            bgt.s   .next
            move.w  #320,(a0)
.next:
            addq.l  #2,a0
            addq.l  #2,a1
            dbra    d7,.loop
            rts

blit_traffic:
            move.w  #$09f0,BLTCON0(a5)
            move.w  #$0000,BLTCON1(a5)
            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.l  a2,BLTAPTH(a5)
            move.l  a1,BLTBPTH(a5)
            move.l  a0,BLTCPTH(a5)
            move.l  a0,BLTDPTH(a5)
            move.w  #0,BLTBMOD(a5)
            move.w  #0,BLTAMOD(a5)
            move.w  #0,BLTCMOD(a5)
            move.w  #0,BLTDMOD(a5)
            move.w  #(8<<6)|1,BLTSIZE(a5)
            rts

draw_scene:
            bsr     clear_bpl
            bsr     draw_frog_sprite
            lea     traffic_x,a0
            lea     traffic_y,a1
            moveq   #0,d7
            move.b  traffic_count,d7
            subq.b  #1,d7
.loop:
            move.w  (a0),d0
            move.w  (a1),d1
            move.w  d1,d2
            mulu    #40,d2
            move.w  d0,d3
            asr.w   #3,d3
            add.w   d3,d2
            lea     bitplane,a2
            adda.w  d2,a2
            lea     traffic_mask,a3
            lea     traffic_img,a4
            move.l  a2,a0
            move.l  a4,a1
            move.l  a3,a2
            bsr     blit_traffic

            addq.l  #2,a0
            addq.l  #2,a1
            dbra    d7,.loop
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
frog_x:         dc.w 0
frog_y:         dc.w 0
traffic_count:  dc.b 0
traffic_x:      ds.w 3
traffic_y:      ds.w 3
traffic_speed:  ds.w 3
bitplane:       ds.b 10240
sprite0:
            dc.w $0000,$0000,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe
            dc.w $7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$0000,$0000
            dc.w $7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe
            dc.w $7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$0000,$0000
            dc.w 0,0
traffic_img:
            dc.w $7ff0,$7ff0,$7ff0,$7ff0,$7ff0,$7ff0,$7ff0,$7ff0
traffic_mask:
            dc.w $fff0,$fff0,$fff0,$fff0,$fff0,$fff0,$fff0,$fff0
gfxname:        dc.b "graphics.library",0
oldview:        dc.l 0
oldcopper:      dc.l 0
gfxbase:        dc.l 0
