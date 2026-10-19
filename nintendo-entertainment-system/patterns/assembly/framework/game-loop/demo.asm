; NTSC NROM. A holds excessive CPU work. NMI only increments the frame clock.
; No rendering/DMC; background palette changes show updates. Reset to leave.
.segment "HEADER"
    .byte "NES",$1a
    .byte 2,1,0,0
    .byte 0,0,0,0,0,0,0,0
.segment "BSS"
updates: .res 2
slow: .res 1
.segment "CODE"
reset:
    sei
    cld
    ldx #$ff
    txs
    inx
    stx $2000
    stx $2001
    stx $4010
    stx $4015
    lda #$40
    sta $4017
    lda #0
clear_ram:
    sta $0000,x
    sta $0100,x
    sta $0200,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne clear_ram
warmup_1:
    bit $2002
    bpl warmup_1
warmup_2:
    bit $2002
    bpl warmup_2
    jsr initialise_clock
    lda #$80
    sta $2000
main_loop:
    jsr wait_frame
    jsr read_controls
    lda controls
    and #$80
    sta slow
    jsr update_game
    jsr draw_screen
    jsr expensive_work
frame_done:
    jmp main_loop
update_game:
    inc updates
    bne update_done
    inc updates+1
update_done:
    rts
draw_screen:
    bit $2002
    lda #$3f
    sta $2006
    lda #0
    sta $2006
    lda updates
    lsr
    lsr
    lsr
    and #$0f
    sta $2007
    lda #0
    sta $2006
    sta $2006
    rts
expensive_work:
    lda slow
    beq work_done
    ldy #64
work_outer:
    ldx #0
work_inner:
    dex
    bne work_inner
    dey
    bne work_outer
work_done:
    rts
nmi:
    inc frame_clock
    rti
irq:
    rti
.include "frame.inc"
.include "../input-to-sound/input.inc"
.segment "VECTORS"
    .word nmi,reset,irq
.segment "CHARS"
    .res 8192,0
