;──────────────────────────────────────────────────────────────
; HOP - Unit 9 sample (Collisions road/water/logs)
; Builds on Unit 8: riding logs. Adds lane-based collision flags.
; Death/lives not implemented here; set death_cause for later units.
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

            bsr     init_state

.mainloop:
            bsr     wait_vb
            bsr     handle_input
            bsr     update_logs
            bsr     ride_logs
            bsr     check_collisions
            bsr     draw_frog
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

init_state:
            move.w  #160,frog_x
            move.w  #220,frog_y
            clr.b   on_log
            clr.w   log_vel_x
            clr.b   death_cause

            move.b  #6,log_count
            lea     log_active,a0
            moveq   #0,d1
            moveq   #5,d2
.clract:
            move.b  d1,(a0)+
            dbra    d2,.clract

            lea     log_spawn,a0
            move.b  #30,(a0)+
            move.b  #50,(a0)+
            move.b  #70,(a0)+
            move.b  #40,(a0)+
            move.b  #60,(a0)+
            move.b  #80,(a0)+

            lea     log_speed,a0
            move.w  #2,(a0)+
            move.w  #-2,(a0)+
            move.w  #2,(a0)+
            move.w  #-2,(a0)+
            move.w  #2,(a0)+
            move.w  #-2,(a0)+

            lea     log_y,a0
            move.w  #120,(a0)+
            move.w  #120,(a0)+
            move.w  #136,(a0)+
            move.w  #136,(a0)+
            move.w  #152,(a0)+
            move.w  #152,(a0)+

            lea     log_x,a0
            move.w  #-64,(a0)+
            move.w  #400,(a0)+
            move.w  #-64,(a0)+
            move.w  #400,(a0)+
            move.w  #-64,(a0)+
            move.w  #400,(a0)+
            rts

handle_input:
            rts

update_logs:
            lea     log_active,a0
            lea     log_x,a1
            lea     log_y,a2
            lea     log_speed,a3
            lea     log_spawn,a4
            moveq   #0,d7
            move.b  log_count,d7
            subq.b  #1,d7
.loop:
            move.b  (a0),d0
            tst.b   d0
            bne.s   .move_active
            move.b  (a4),d1
            subq.b  #1,d1
            move.b  d1,(a4)
            bne.s   .next
            move.b  #1,(a0)
            move.b  #40,(a4)
            move.w  (a3),d2
            tst.w   d2
            bpl.s   .spawn_left
            move.w  #400,(a1)
            bra.s   .next
.spawn_left:
            move.w  #-64,(a1)
            bra.s   .next
.move_active:
            move.w  (a1),d2
            add.w   (a3),d2
            move.w  d2,(a1)
            cmp.w   #400,d2
            blt.s   .chk_left
            move.b  #0,(a0)
            move.b  #40,(a4)
            bra.s   .next
.chk_left:
            cmp.w   #-80,d2
            bgt.s   .next
            move.b  #0,(a0)
            move.b  #40,(a4)
.next:
            addq.l  #1,a0
            addq.l  #2,a1
            addq.l  #2,a2
            addq.l  #2,a3
            addq.l  #1,a4
            dbra    d7,.loop
            rts

ride_logs:
            clr.b   on_log
            clr.w   log_vel_x
            move.w  frog_x,d4
            move.w  frog_y,d5

            lea     log_active,a0
            lea     log_x,a1
            lea     log_y,a2
            lea     log_speed,a3
            moveq   #0,d7
            move.b  log_count,d7
            subq.b  #1,d7
.rloop:
            move.b  (a0),d0
            tst.b   d0
            beq.s   .rnext
            move.w  (a1),d1
            move.w  (a2),d2
            move.w  #48,d3
            move.w  #8,d6
            cmp.w   d2,d5
            bcs.s   .rnext
            move.w  d2,d0
            add.w   d6,d0
            cmp.w   d0,d5
            bcc.s   .rnext
            cmp.w   d1,d4
            bcs.s   .rnext
            move.w  d1,d0
            add.w   d3,d0
            cmp.w   d0,d4
            bcc.s   .rnext
            move.b  #1,on_log
            move.w  (a3),log_vel_x
.rnext:
            addq.l  #1,a0
            addq.l  #2,a1
            addq.l  #2,a2
            addq.l  #2,a3
            dbra    d7,.rloop

            tst.b   on_log
            beq.s   .no_ride
            move.w  frog_x,d0
            add.w   log_vel_x,d0
            move.w  d0,frog_x
.no_ride:
            rts

check_collisions:
            ; lane bands: road ~96-112, water ~120-168, start/home others
            move.w  frog_y,d0
            cmpi.w  #112,d0
            blt.s   .road_check
            cmpi.w  #168,d0
            blt.s   .water_check
            ; safe lanes
            clr.b   death_cause
            rts

.road_check:
            ; placeholder: if x within car region -> death
            ; set death_cause=0 for car
            rts

.water_check:
            tst.b   on_log
            bne.s   .safe
            move.b  #1,death_cause   ; drown
.safe:      rts

draw_frog:
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
frog_x:       dc.w 0
frog_y:       dc.w 0
on_log:       dc.b 0
log_vel_x:    dc.w 0

log_count:    dc.b 0
log_active:   ds.b 6
log_spawn:    ds.b 6
log_x:        ds.w 6
log_y:        ds.w 6
log_speed:    ds.w 6

death_cause:  dc.b 0

gfxname:      dc.b "graphics.library",0
oldview:      dc.l 0
oldcopper:    dc.l 0
gfxbase:      dc.l 0
