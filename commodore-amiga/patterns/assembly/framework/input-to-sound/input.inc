; Digital joystick in physical port 2 (JOY1DAT), fire on CIA-A bit 7.
; A5=$dff000; caller owns the port and configures CIA-A bit 7 as input.
; Output controls: up=$0100, down=$0001, left=$0200, right=$0002, fire=$0010.
; Clobbers D0/D1 and CCR; state must be in writable RAM. Other registers survive.
read_controls:
    move.w $00c(a5),d0
    move.w d0,d1
    lsr.w #1,d1
    eor.w d0,d1
    and.w #$0101,d1       ; decoded vertical bits only
    and.w #$0202,d0       ; retain original horizontal bits
    or.w d1,d0
    btst #7,$bfe001
    bne.s input_no_fire
    or.w #$0010,d0
input_no_fire:
    move.w d0,controls
    rts
controls: dc.w 0
