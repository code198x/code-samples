.segment "BSS"
DEADLINE: .res 12
STATE: .res 10
ready: .res 1
status_row: .res 8
display_row: .res 8
caller_state_end:
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
    jsr wait_vblank
    jsr wait_vblank
    bit $2002
    lda #$20
    sta $2006
    lda #0
    sta $2006
    ldy #4
    ldx #0
clear_names:
    sta $2007
    inx
    bne clear_names
    dey
    bne clear_names
    lda #$3f
    sta $2006
    lda #0
    sta $2006
    lda #$0f
    sta $2007
    lda #$30
    sta $2007
    lda #<DURATION
    sta DEADLINE
    lda #>DURATION
    sta DEADLINE+1
    jsr read_clock
    jsr deadline_init
    jsr initialise_clock
    lda #165
    sta ready
    lda #$0a
    sta $2001
    lda #$80
    sta $2000
main_loop:
    jsr wait_frame
    jsr read_clock
    jsr POLL_ROUTINE
    jsr read_controls
    jsr detect_presses
    lda #0
    sta STATE+7
    sta STATE+8
    lda new_presses
    and #$80
    beq no_action
    inc STATE+8
no_action:
    lda new_presses
    and #$20
    beq no_toggle
    lda STATE+8
    ora #2
    sta STATE+8
no_toggle:
    jsr dispatch
    inc STATE
    bne update_done
    inc STATE+1
update_done:
    lda STATE+4
    sta status_row
    lda STATE+5
    sta status_row+1
    lda STATE+6
    sta status_row+2
    lda DEADLINE+4
    sta status_row+3
    lda DEADLINE+2
    sta status_row+4
    lda DEADLINE+3
    sta status_row+5
    lda DEADLINE+10
    sta status_row+6
    lda DEADLINE+11
    sta status_row+7
; Fresh vblank protects the transfer even after slow work.
    jsr wait_vblank
    lda controls
    and #$10
    bne work_start
    bit $2002
    lda #$20
    sta $2006
    lda #$22
    sta $2006
    ldy #0
show_status:
    lda status_row,y
    sta display_row,y
    jsr show_byte
    iny
    cpy #8
    bne show_status
    lda #$80
    sta $2000
    lda #0
    sta $2005
    sta $2005
work_start:
; Held Start freezes only the displayed row; timing and turns continue.
; Held B is diagnostic work after the transfer. NMI still owns the clock.
    lda controls
    and #$40
    beq frame_done
    ldy #64
work_outer:
    ldx #0
work_inner:
    dex
    bne work_inner
    dey
    bne work_outer
frame_done:
    jmp main_loop
commit_turn:
    inc STATE+4
    bne turn_committed
    inc STATE+5
turn_committed:
    inc STATE+7
    rts
show_byte:
    pha
    lsr
    lsr
    lsr
    lsr
    clc
    adc #1
    sta $2007
    pla
    and #15
    clc
    adc #1
    sta $2007
    lda #0
    sta $2007
    rts
wait_vblank:
    bit $2002
    bpl wait_vblank
    rts
nmi:
    jsr clock_tick
irq:
    rti
