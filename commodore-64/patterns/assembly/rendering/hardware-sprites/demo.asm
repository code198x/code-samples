; Load the PRG, then RUN. Reset to leave this standalone demonstration.
; It owns the screen, VIC bank, CIA interrupt masks and sprite registers.
DEMO_X = 160
DEMO_Y = 120
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
    ; Guest snapshots make shared-bit preservation observable.
    ldx #0
copy_registers:
    lda $d000, x
    sta observed, x
    inx
    cpx #$2f
    bne copy_registers
    lda $07f8
    sta observed_pointer
wait_top:
    bit $d011
    bmi wait_top
wait_bottom:
    bit $d011
    bpl wait_bottom
    inc frames
    jmp wait_top
nmi_return:
    rti
frames:
    !byte 0
observed:
    !fill $2f, 0
observed_pointer:
    !byte 0

!source "sprite.inc"
!source "shape.inc"
blank_shape:
    !fill 64, 0
