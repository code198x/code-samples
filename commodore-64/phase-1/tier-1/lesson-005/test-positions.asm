; Test sprite positions to understand C64 screen boundaries
!to "test-positions.prg", cbm

*=$0801
        !byte $0b,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*=$080d
main:
        ; Setup
        lda #$00
        sta $d021
        lda #$03
        sta $d020
        
        ; Deploy sprite
        lda #$0d
        sta $07f8
        ldx #0
copy_sprite:
        lda sprite_pattern,x
        sta $0340,x
        inx
        cpx #63
        bne copy_sprite
        
        ; Enable sprite
        lda #$01
        sta $d015
        lda #$03
        sta $d027
        
        ; Test different X positions
        lda #$00            ; Start at X=0
        sta test_x
        
test_loop:
        ; Set sprite position
        lda test_x
        sta $d000
        lda test_x_msb
        beq no_msb
        lda #$01
        sta $d010
        jmp set_y
no_msb:
        lda #$00
        sta $d010
set_y:
        lda #100
        sta $d001
        
        ; Show current X on screen
        lda test_x
        lsr
        lsr
        lsr
        lsr                 ; Get high nibble
        sta $0400+5*40+0
        lda test_x
        and #$0f            ; Get low nibble
        sta $0400+5*40+1
        
        ; Show MSB
        lda test_x_msb
        sta $0400+5*40+3
        
        ; Wait for input
wait_key:
        lda $dc00
        and #$10            ; Fire button
        bne wait_key
        
        ; Wait for release
wait_release:
        lda $dc00
        and #$10
        beq wait_release
        
        ; Next position
        lda test_x
        clc
        adc #32             ; Jump by 32 pixels
        sta test_x
        bcc test_loop       ; No overflow
        
        ; Handle overflow to MSB
        lda test_x_msb
        eor #$01
        sta test_x_msb
        jmp test_loop

; Data
test_x:     !byte 0
test_x_msb: !byte 0

; Simple sprite pattern
sprite_pattern:
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111
        !byte %11111111,%11111111,%11111111