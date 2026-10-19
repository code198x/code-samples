; NTSC NROM. Controller 1 A plays pulse 1; release stops it. Reset to leave.
; Whole-program ownership: no NMI/music driver, DMC or other APU channels.
.segment "HEADER"
    .byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
.segment "BSS"
trigger_count: .res 1
updates: .res 2
audio_status: .res 1
.segment "CODE"
reset:
    sei
    cld
    ldx #$40
    stx $4017              ; inhibit APU frame IRQ
    ldx #$ff
    txs
    inx
    stx $2000              ; no NMI
    stx $2001              ; rendering off: use background colour only
    stx $4010              ; no DMC IRQ
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
    lda #0
    sta trigger_count
    sta updates
    sta updates+1
    jsr initialise_input
wait_frame:
    jsr wait_vblank
    jsr update_input
    lda new_presses
    and #$80
    beq show_state
    inc trigger_count
show_state:
    bit $2002
    lda #$3f
    sta $2006
    lda #0
    sta $2006
    lda trigger_count
    and #$0f
    sta $2007              ; visible colour changes once per new A press
    lda #0                 ; leave VRAM address outside palette RAM
    sta $2006
    sta $2006
    lda $4015
    sta audio_status
    inc updates
    bne frame_done
    inc updates+1
frame_done:
    jmp wait_frame
wait_vblank:
    bit $2002
    bpl wait_vblank
    rts
nmi:
irq:
    rti
.include "input.inc"
.include "presses.inc"
.include "tone.inc"
.include "use.asm"
.segment "VECTORS"
    .word nmi,reset,irq
.segment "CHARS"
    .res 8192,0
