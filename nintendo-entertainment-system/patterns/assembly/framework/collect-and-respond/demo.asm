; NTSC NROM, D-pad moves, A restarts. No DMC. NMI owns only frame_clock.
.segment "HEADER"
    .byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
.segment "BSS"
previous: .res 1
pressed: .res 1
released: .res 1
player_x: .res 1
player_y: .res 1
item_active: .res 1
score: .res 1
move_delay: .res 1
sound_ticks: .res 1
old_x: .res 1
old_y: .res 1
updates: .res 1
raw_controls: .res 1
draw_y: .res 1
draw_tile: .res 1
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

    ; Rendering is off: initialise nametable, attributes and palettes.
    bit $2002
    lda #$20
    sta $2006
    lda #0
    sta $2006
    ldy #4
    ldx #0
clear_picture:
    sta $2007
    inx
    bne clear_picture
    dey
    bne clear_picture
    lda #$3f
    sta $2006
    lda #0
    sta $2006
    lda #$0f
    sta $2007
    lda #$30
    sta $2007
    jsr reset_game
    jsr initialise_clock
    lda #$80
    sta $2000
    lda #$0a
    sta $2001
main_loop:
    jsr wait_frame
    jsr read_controls
    jsr map_controls
    jsr detect_edges
    jsr service_sound
    jsr update_player
    jsr draw_screen
    inc updates
frame_done:
    jmp main_loop
nmi:
    inc frame_clock
    rti
irq: rti
.include "rules.inc"
.include "draw.inc"
.include "sound.inc"
.include "../game-loop/frame.inc"
.include "../input-to-sound/input.inc"
.include "../../audio/square-wave/square-wave.inc"
.include "collision.inc"
.segment "VECTORS"
    .word nmi,reset,irq
.segment "CHARS"
; Tile 0 blank; tiles 1/2 player/collectible; 3/4 digits 0/1. Plane 1 zero.
    .res 16,0
    .byte 24,60,126,219,255,90,36,0
    .res 8,0
    .byte 0,24,90,60,90,24,0,0
    .res 8,0
    .byte 60,66,70,74,82,98,60,0
    .res 8,0
    .byte 24,56,24,24,24,24,126,0
    .res 8,0
    .res 8112,0
