; GRID PROTOCOL: Fixed version that actually works
!to "grid-fixed.prg", cbm

; Use a lookup table instead of broken multiplication
GRID_WIDTH = 12
GRID_HEIGHT = 8

*=$0801
        !byte $0b,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*=$080d
main:
        ; Setup
        lda #$00
        sta $d021
        lda #$03
        sta $d020
        
        jsr clear_screen
        jsr deploy_entity
        
        ; Start at grid center
        lda #6
        sta grid_x
        lda #4                  ; Center of 8 rows (0-7)
        sta grid_y
        
        ; Enable sprite
        lda #$01
        sta $d015
        lda #$03
        sta $d027
        
game_loop:
        jsr read_input
        jsr move_grid
        jsr update_position
        jsr wait_frame
        jmp game_loop

read_input:
        lda $dc00
        sta input_state
        rts

move_grid:
        lda input_state
        
        ; Up
        and #$01
        bne check_down
        lda grid_y
        beq check_down
        dec grid_y
        jsr wait_release
        
check_down:
        lda input_state
        and #$02
        bne check_left
        lda grid_y
        cmp #GRID_HEIGHT-1
        beq check_left
        inc grid_y
        jsr wait_release
        
check_left:
        lda input_state
        and #$04
        bne check_right
        lda grid_x
        beq check_right
        dec grid_x
        jsr wait_release
        
check_right:
        lda input_state
        and #$08
        bne move_done
        lda grid_x
        cmp #GRID_WIDTH-1
        beq move_done
        inc grid_x
        jsr wait_release
        
move_done:
        rts

update_position:
        ; Use lookup table for X positions
        ldx grid_x
        lda x_positions,x
        sta $d000
        lda x_msb_flags,x
        sta $d010
        
        ; Simple Y calculation: Y = grid_y * 30 + 60
        lda grid_y
        asl                     ; *2
        asl                     ; *4
        asl                     ; *8
        sta temp_y              ; Save *8
        asl                     ; *16
        clc
        adc temp_y              ; *16 + *8 = *24
        asl                     ; *48... no wait
        
        ; Let's just use another lookup table
        ldx grid_y
        lda y_positions,x
        sta $d001
        
        ; Debug: show grid position as background color
        lda grid_x
        clc
        adc #1
        sta $d021
        
        rts

wait_release:
        lda $dc00
        and #$0f
        cmp #$0f
        bne wait_release
        rts

deploy_entity:
        lda #$0d
        sta $07f8
        ldx #0
copy_sprite:
        lda sprite_data,x
        sta $0340,x
        inx
        cpx #63
        bne copy_sprite
        rts

clear_screen:
        ldx #0
clear_loop:
        lda #$20
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        lda #$03
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $db00,x
        inx
        bne clear_loop
        rts

wait_frame:
        lda #251
wait_raster:
        cmp $d012
        bne wait_raster
        rts

; Data
grid_x:         !byte 6
grid_y:         !byte 3
input_state:    !byte 0
temp_y:         !byte 0

; X position lookup table - better margins (28 to 316, 26.2 pixels apart)
x_positions:
        !byte 28, 54, 80, 106, 132, 158, 184, 210, 236, 6, 32, 58

; MSB flags (0 for positions < 256, 1 for positions >= 256)  
x_msb_flags:
        !byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1

; Y positions - 8 rows with better top margin (55, 77, 99, 121, 143, 165, 187, 209)
y_positions:
        !byte 55, 77, 99, 121, 143, 165, 187, 209

sprite_data:
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000011,%11111111,%11000000
        !byte %00000111,%11111111,%11100000
        !byte %00001111,%11111111,%11110000
        !byte %00011111,%11111111,%11111000
        !byte %00111111,%11111111,%11111100
        !byte %01111111,%11111111,%11111110
        !byte %11111111,%11111111,%11111111
        !byte %01111111,%11111111,%11111110
        !byte %00111111,%11111111,%11111100
        !byte %00011111,%11111111,%11111000
        !byte %00001111,%11111111,%11110000
        !byte %00000111,%11111111,%11100000
        !byte %00000011,%11111111,%11000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00011000,%00000000