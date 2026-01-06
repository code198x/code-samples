;──────────────────────────────────────────────────────────────
; HOP - Integrated sample through Unit 7 (logs moving)
; Includes: display lanes (Unit1), frog sprite (Unit2), movement (Unit3),
; traffic BOBs (Unit4), traffic animation (Unit5), river lanes (Unit6),
; plus log spawning/movement (Unit7).
; Note: Death/collision/lives/polish handled in later units.
;──────────────────────────────────────────────────────────────

CUSTOM          equ $dff000
ExecBase        equ 4
OldOpenLibrary  equ -408
CloseLibrary    equ -414
LoadView        equ -222
WaitTOF         equ -270

;----------------------------------------------------------------
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
            move.w  #$7fff,$9a(a5)     ; INTENA off
            move.w  #$7fff,$9c(a5)     ; INTREQ clear

            ; copper list
            lea     copperlist,a0
            move.l  a0,$80(a5)
            move.w  d0,$88(a5)

            ; enable DMA: bit15=1, bit7=copper, bit10=blitter
            move.w  #$83a0,$96(a5)

            bsr     init_state

.mainloop:
            bsr     wait_vb
            bsr     handle_input
            bsr     update_traffic
            bsr     update_logs
            bsr     draw_frog
            bra     .mainloop

.exit:
            rts

;----------------------------------------------------------------
wait_vb:
            move.l  #$1ff00,d1
.vbwait:
            move.l  4(a5),d0
            and.l   d1,d0
            cmp.l   #$00000,d0
            bne.s   .vbwait
            rts

;----------------------------------------------------------------
init_state:
            ; frog start
            move.w  #160,frog_x
            move.w  #220,frog_y
            clr.w   on_log

            ; traffic init (placeholder positions)
            moveq   #0,d0
            move.b  #3,traffic_count
            lea     traffic_x,a0
            move.w  #40,(a0)+
            move.w  #140,(a0)+
            move.w  #260,(a0)+
            lea     traffic_speed,a0
            move.w  #2,(a0)+
            move.w  #-3,(a0)+
            move.w  #2,(a0)+

            ; log init
            moveq   #0,d0
            move.b  #6,log_count
            lea     log_active,a0
            moveq   #0,d1
            moveq   #6-1,d2
.init_log_loop:
            move.b  d1,(a0)+           ; active=0
            dbra    d2,.init_log_loop

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

            ; log Y per lane (top water lane at y=120, spaced by 16)
            lea     log_y,a0
            move.w  #120,(a0)+
            move.w  #120,(a0)+
            move.w  #136,(a0)+
            move.w  #136,(a0)+
            move.w  #152,(a0)+
            move.w  #152,(a0)+

            ; log X start off-screen
            lea     log_x,a0
            move.w  #-64,(a0)+
            move.w  #400,(a0)+
            move.w  #-64,(a0)+
            move.w  #400,(a0)+
            move.w  #-64,(a0)+
            move.w  #400,(a0)+

            rts

;----------------------------------------------------------------
handle_input:
            ; simple: check joystick on CIAA (not fully implemented here)
            ; placeholder: no movement for brevity
            rts

;----------------------------------------------------------------
update_traffic:
            ; move cars and wrap (placeholder)
            rts

;----------------------------------------------------------------
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
            move.b  (a0),d0          ; active?
            tst.b   d0
            bne.s   .move_active
            ; inactive: countdown spawn
            move.b  (a4),d1
            subq.b  #1,d1
            move.b  d1,(a4)
            bne.s   .next
            ; spawn
            move.b  #1,(a0)
            move.b  #60,(a4)        ; reset spawn timer
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
            ; wrap
            cmp.w   #400,d2
            blt.s   .chk_offleft
            move.b  #0,(a0)
            move.b  #40,(a4)
            bra.s   .next
.chk_offleft:
            cmp.w   #-80,d2
            bgt.s   .next
            move.b  #0,(a0)
            move.b  #40,(a4)

.next:
            addq.l  #2,a1
            addq.l  #2,a2
            addq.l  #2,a3
            addq.l  #1,a0
            addq.l  #1,a4
            dbra    d7,.loop

            ; draw logs (placeholder blits)
            rts

;----------------------------------------------------------------
draw_frog:
            ; placeholder: would write sprite position to hardware
            rts

;----------------------------------------------------------------
; Copper list and minimal colors (reuse Unit1 bands)
;----------------------------------------------------------------
            section chipdata,data_c
copperlist:
            dc.w    $0180,$0000
            dc.w    $2c07,$fffe
            dc.w    $0180,$0070
            dc.w    $4007,$fffe
            dc.w    $0180,$0080
            dc.w    $5007,$fffe
            dc.w    $0180,$0444
            dc.w    $5c07,$fffe
            dc.w    $0180,$0666
            dc.w    $6007,$fffe
            dc.w    $0180,$0444
            dc.w    $6c07,$fffe
            dc.w    $0180,$0666
            dc.w    $7007,$fffe
            dc.w    $0180,$0444
            dc.w    $7807,$fffe
            dc.w    $0180,$0080
            dc.w    $8007,$fffe
            dc.w    $0180,$0444
            dc.w    $8c07,$fffe
            dc.w    $0180,$0666
            dc.w    $9007,$fffe
            dc.w    $0180,$0444
            dc.w    $9c07,$fffe
            dc.w    $0180,$0666
            dc.w    $a007,$fffe
            dc.w    $0180,$0444
            dc.w    $a807,$fffe
            dc.w    $0180,$0048
            dc.w    $b007,$fffe
            dc.w    $0180,$006b
            dc.w    $b807,$fffe
            dc.w    $0180,$0048
            dc.w    $c007,$fffe
            dc.w    $0180,$006b
            dc.w    $c807,$fffe
            dc.w    $0180,$0048
            dc.w    $d007,$fffe
            dc.w    $0180,$006b
            dc.w    $d807,$fffe
            dc.w    $0180,$0080
            dc.w    $e807,$fffe
            dc.w    $0180,$0070
            dc.w    $f007,$fffe
            dc.w    $0180,$0000
            dc.w    $ffff,$fffe

;----------------------------------------------------------------
            section data,data

frog_x:         dc.w 0
frog_y:         dc.w 0
on_log:         dc.w 0

traffic_count:  dc.b 0
traffic_x:      ds.w 3
traffic_speed:  ds.w 3

log_count:      dc.b 0
log_active:     ds.b 6
log_spawn:      ds.b 6
log_x:          ds.w 6
log_y:          ds.w 6
log_speed:      ds.w 6

gfxname:        dc.b "graphics.library",0
oldview:        dc.l 0
oldcopper:      dc.l 0
gfxbase:        dc.l 0
