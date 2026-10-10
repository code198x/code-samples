; Load, RUN, then use joystick port 2. Reset to leave.
; It owns the screen, VIC bank, CIA interrupt masks and sprite registers.
DEMO_X = 160
DEMO_Y = 140
SHARED_SEED = 0             ; verification seeds bits belonging to other sprites

* = $0801
    !byte $0b, $08, $0a, $00, $9e
    !text "2064"
    !byte 0, 0, 0
* = $0810
start:
    sei
    lda #$7f
    sta $dc0d
    sta $dd0d
    lda $dc0d
    lda $dd0d
    lda #$35
    sta $01                  ; RAM at BASIC/KERNAL, I/O visible
    lda #<nmi_return
    sta $fffa
    lda #>nmi_return
    sta $fffb
    lda $dd02
    ora #3
    sta $dd02
    lda $dd00
    ora #3
    sta $dd00                ; VIC bank 0
    lda #$14
    sta $d018                ; screen $0400, character ROM $1000
    lda #$1b
    sta $d011                ; display on, normal text
    lda #$08
    sta $d016                ; 40 columns, single-colour text
    lda #0
    sta $d015
    sta $d020
    sta $d021
    ldx #0
    lda #32
clear_screen:
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $06e8, x
    inx
    bne clear_screen
    ; Blank shapes keep the other sprites invisible during ownership checks.
    ldx #7
    lda #$81
blank_pointers:
    sta $07f8, x
    dex
    bpl blank_pointers
    lda #SHARED_SEED
    sta $d015
    ora #1                   ; sprite 0 starts with wrong high/mode bits
    sta $d010
    sta $d017
    sta $d01b
    sta $d01c
    sta $d01d
    lda #<DEMO_X
    ldx #>DEMO_X
    ldy #DEMO_Y
    jsr sprite0_show
    lda #0
    sta $dc02                ; both CIA1 ports input: no keyboard scanning
    sta $dc03
    lda #<DEMO_X
    sta sprite_x_lo
    lda #>DEMO_X
    sta sprite_x_hi
    lda #DEMO_Y
    sta sprite_y
    jmp wait_top
    ; Guest snapshots make input, movement and shared bits observable.
copy_registers_start:
    ldx #0
copy_registers:
    lda $d000, x
    sta observed, x
    inx
    cpx #$2f
    bne copy_registers
    inc frames
frame_done:
    jmp wait_top
wait_top:
    bit $d011
    bmi wait_top
wait_picture_end:
    lda $d012
    cmp #250
    bne wait_picture_end
picture_ready:               ; debugger observation point; completed picture
wait_bottom:
    bit $d011
    bpl wait_bottom
    jsr read_joystick2
    jsr move_sprite
    jmp copy_registers_start
nmi_return:
    rti
frames:
    !byte 0
observed:
    !fill $2f, 0

read_joystick2:
    lda $dc00
    eor #$ff
    and #$0f
    rts

!source "movement.inc"
!source "../../rendering/hardware-sprites/sprite.inc"
!source "../../rendering/hardware-sprites/shape.inc"
blank_shape:
    !fill 64, 0
