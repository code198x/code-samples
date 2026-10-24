start:
    lea $dff000,a5
    move.w #$7fff,$09a(a5)
    move.w #$7fff,$09c(a5)
    move.w #$7fff,$096(a5)
    bclr #7,$bfe201
    lea plane,a0
    move.l a0,d0
    lea copbpl,a1
    move.w d0,6(a1)
    swap d0
    move.w d0,2(a1)
    lea copperlist,a0
    move.l a0,$080(a5)
    move.w #0,$088(a5)
    move.w #$8380,$096(a5)
    move.w #$c000,$09a(a5)
    bsr clock_install
    cmpi.w #1,d0
    bne failed
    lea deadline,a0
    move.w #DURATION,(a0)
    bsr read_clock
    bsr deadline_init
    clr.w joy_prev
    move.w #$cafe,ready
main_loop:
    bsr read_joystick_edge
    move.w d0,pressed
    lea deadline,a0
    bsr read_clock
    bsr POLL_ROUTINE
    bsr dispatch
    addq.w #1,updates
    move.w turns,status_row
    move.w expiries,status_row+2
    move.w deadline+4,status_row+4
    move.w deadline+2,status_row+6
    move.w deadline+12,status_row+8
    move.w updates,status_row+10
    move.w #DURATION,status_row+12
; Deliberate foreground work; IRQ clock continues independently.
    move.w controls,d0
    andi.w #2,d0
    beq wait_display
    move.w #30000,d0
work_loop:
    dbra d0,work_loop
wait_display:
    bsr wait_clock_frame
    move.w controls,d0
    andi.w #$0200,d0
    bne frame_done
    bsr draw_status
frame_done:
    bra main_loop
commit_turn:
    addq.w #1,turns
    rts
failed:
    move.w #$f00,$180(a5)
    bra failed
caller_code_end:
signature: dc.b "198XAMIGATIMER!",0
    even
ready: dc.w 0
turns: dc.w 0
expiries: dc.w 0
updates: dc.w 0
pressed: dc.w 0
deadline: dcb.w 7,0
status_row: dcb.w 7,0
display_row: dcb.w 7,0
    even
copperlist:
    dc.w $08e,$2c81,$090,$2cc1,$092,$0038,$094,$00d0
    dc.w $100,$1200,$102,0,$104,0,$108,0,$10a,0
    dc.w $180,$012,$182,$fff
copbpl:
    dc.w $0e0,0,$0e2,0
    dc.w $ffff,$fffe
plane: dcb.b 10240,0
