; Standalone stock-ROM PRG. Takes ownership; does not return to BASIC.
*=$0801
    !byte $0b,$08,$0a,$00,$9e
    !text "2064"
    !byte 0,0,0
*=$0810
G=$70
CPU_MAP=$35
start:
    sei
    cld
    lda #$7f
    sta $dc0d
    sta $dd0d
    lda $dc0d
    lda $dd0d
    lda #0
    sta $d01a
    sta $d015
    sta $d020
    sta $d021
    lda #<safe_interrupt
    sta $fffa
    sta $fffe
    lda #>safe_interrupt
    sta $fffb
    sta $ffff
    lda #CPU_MAP
    sta $01
    lda $dd02
    ora #3
    sta $dd02
    lda $dd00
    ora #3
    sta $dd00
    lda #$1b
    sta $d011
    lda #8
    sta $d016
    lda #$18
    sta $d018
    ldx #0
    lda #32
clear_screen:
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne clear_screen
    lda #1
colours:
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $db00,x
    inx
    bne colours
    lda #$a5
font_guards:
    sta $1ff0,x
    sta $2800,x
    inx
    cpx #16
    bne font_guards
    ldx #0
banner_copy:
    lda banner,x
    sta $0400,x
    inx
    cpx #13
    bne banner_copy
    lda #<patterns
    sta G
    lda #>patterns
    sta G+1
    lda #1
    sta G+2
    sta G+3
    sta G+4
    lda #82
    sta G+5
    lda #0
    sta G+6
    lda #HALF
    ldx #CPU_MAP
    jsr glyph_init_rom
    lda G+7
    sta init_status
    lda G+8
    sta init_writes
    lda G+9
    sta init_writes+1
    lda $01
    sta restored_port
    jsr joy_init
    lda #$a5
    sta ready
init_done:
    jsr joy_poll
    lda joy2
    and #16
    beq init_done
initial_release:
    jsr joy_poll
    lda joy2
    and #16
    bne initial_release
; The second caller and observer can stop here before any glyph is patched.
    jsr glyph_install
    jsr glyph_select
    inc G+5
    jsr glyph_select
    lda #0
    sta pressed_before
main_loop:
    jsr joy_poll
    lda joy2
    and #16
    beq no_fire
    lda pressed_before
    bne frame_done
    lda #<patterns+8
    sta G
    lda #>patterns+8
    sta G+1
    jsr glyph_replace
    inc changes
no_fire:
    lda joy2
    and #16
    sta pressed_before
frame_done:
    jmp main_loop
safe_interrupt:
    rti
ready: !byte 0
init_status: !byte 0
init_writes: !word 0
restored_port: !byte 0
pressed_before: !byte 0
changes: !byte 0
banner: !byte 18,15,13,32,6,15,14,20,32,11,5,16,20
patterns: !byte 129,66,36,24,24,36,66,129
          !byte 255,129,129,129,129,129,129,255
    !source "glyphs.inc"
    !source "rom-init.inc"
    !source "../../input/joystick-reading/joystick.inc"
program_end:
