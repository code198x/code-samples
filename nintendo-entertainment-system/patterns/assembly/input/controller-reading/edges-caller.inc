.segment "BSS"
actions: .res 1
last_new: .res 1
last_release: .res 1
press_events: .res 1
release_events: .res 1
ready: .res 1
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
    lda #165
    sta ready
    lda #$0a
    sta $2001
wait_frame:
    jsr wait_vblank
sample:
    jsr read_controls
    jsr POLL_ROUTINE
    lda new_presses
    beq no_press
    sta last_new
    inc press_events
no_press:
    lda released_controls
    beq no_release
    sta last_release
    inc release_events
no_release:
    lda new_presses
    and #ACTION_MASK
    beq show_state
    inc actions
show_state:
    bit $2002
    lda #$20
    sta $2006
    lda #$22
    sta $2006
    lda controls
    jsr show_byte
    lda new_presses
    jsr show_byte
    lda released_controls
    jsr show_byte
    lda actions
    jsr show_byte
    lda #0
    sta $2000
    sta $2005
    sta $2005
frame_done:
    jmp wait_frame
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
irq:
    rti
