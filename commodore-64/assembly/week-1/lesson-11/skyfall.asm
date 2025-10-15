; SKYFALL - Lesson 11
; Random spawning

* = $0801

; BASIC stub: SYS 2061
!byte $0c,$08,$0a,$00,$9e
!byte $32,$30,$36,$31          ; "2061" in ASCII
!byte $00,$00,$00

* = $080d

; ===================================
; Constants
; ===================================
SCREEN_RAM = $0400
COLOR_RAM = $d800
VIC_BORDER = $d020
VIC_BACKGROUND = $d021
CIA1_PORT_A = $dc01
CIA1_PORT_B = $dc00
VIC_RASTER = $d012

SID_V3_FREQ_LO = $d40e
SID_V3_FREQ_HI = $d40f
SID_V3_CONTROL = $d412
SID_V3_OSC = $d41b

BLACK = $00
WHITE = $01
YELLOW = $07
DARK_GREY = $0b

PLAYER_CHAR = $1e
PLAYER_COLOR = WHITE
PLAYER_ROW = 23
PLAYER_START_COL = 20

OBJECT_CHAR = $2a
OBJECT_COLOR = YELLOW

; Variables
PLAYER_COL = $02
MOVE_COUNTER = $03
OBJ_COL = $04
OBJ_ROW = $05
OBJ_ACTIVE = $06
FALL_COUNTER = $07
SCORE = $08
MISSES = $09

; ===================================
; Main Program
; ===================================
main:
    jsr init_screen
    jsr init_random            ; Initialize random number generator

    lda #PLAYER_START_COL
    sta PLAYER_COL

    lda #3
    sta MOVE_COUNTER

    lda #5
    sta FALL_COUNTER

    lda #$00
    sta SCORE
    sta MISSES

    jsr draw_player
    jsr spawn_object
    jsr display_score
    jsr display_misses

game_loop:
    jsr wait_for_raster

    ; Player movement (every 3 frames)
    dec MOVE_COUNTER
    bne skip_player_movement
    lda #3
    sta MOVE_COUNTER
    jsr check_keys
skip_player_movement:

    ; Object falling (every 5 frames)
    dec FALL_COUNTER
    bne skip_object_fall
    lda #5
    sta FALL_COUNTER
    jsr update_object
    jsr check_collision
    jsr draw_player           ; Redraw player (in case object erased it)
skip_object_fall:

    jmp game_loop

; ===================================
; Subroutines
; ===================================

wait_for_raster:
    lda VIC_RASTER
    cmp #250
    bne wait_for_raster
    rts

init_screen:
    jsr wait_for_raster
    lda #BLACK
    sta VIC_BACKGROUND
    lda #DARK_GREY
    sta VIC_BORDER
    jsr clear_screen
    rts

init_random:
    ; Set up SID voice 3 for random number generation
    lda #$ff
    sta SID_V3_FREQ_LO
    sta SID_V3_FREQ_HI

    lda #$80                   ; Noise waveform
    sta SID_V3_CONTROL
    rts

get_random:
    ; Returns random byte 0-255 in A
    lda SID_V3_OSC
    rts

get_random_column:
    ; Returns random column 0-39 in A
try_again:
    jsr get_random
    and #%00111111             ; Keep lower 6 bits (0-63)
    cmp #40
    bcs try_again              ; If >= 40, try again
    rts

clear_screen:
    lda #$20
    ldx #$00
clear_screen_loop:
    sta SCREEN_RAM,x
    sta SCREEN_RAM + $100,x
    sta SCREEN_RAM + $200,x
    sta SCREEN_RAM + $300,x
    inx
    bne clear_screen_loop

    lda #WHITE
    ldx #$00
clear_color_loop:
    sta COLOR_RAM,x
    sta COLOR_RAM + $100,x
    sta COLOR_RAM + $200,x
    sta COLOR_RAM + $300,x
    inx
    bne clear_color_loop
    rts

check_keys:
    ; Check D key (column 2, row 2)
    lda #%11111011
    sta CIA1_PORT_B
    lda CIA1_PORT_A
    and #%00000100
    beq move_right

    ; Check A key (column 1, row 2)
    lda #%11111101
    sta CIA1_PORT_B
    lda CIA1_PORT_A
    and #%00000100
    beq move_left

    rts

move_left:
    lda PLAYER_COL
    beq skip_left

    jsr erase_player
    dec PLAYER_COL
    jsr draw_player

skip_left:
    rts

move_right:
    lda PLAYER_COL
    cmp #39
    beq skip_right

    jsr erase_player
    inc PLAYER_COL
    jsr draw_player

skip_right:
    rts

erase_player:
    ldx PLAYER_COL
    lda #$20
    sta SCREEN_RAM + (PLAYER_ROW * 40),x
    rts

draw_player:
    ldx PLAYER_COL
    lda #PLAYER_CHAR
    sta SCREEN_RAM + (PLAYER_ROW * 40),x

    lda #PLAYER_COLOR
    sta COLOR_RAM + (PLAYER_ROW * 40),x
    rts

spawn_object:
    lda #$01
    sta OBJ_ACTIVE

    lda #$00
    sta OBJ_ROW

    jsr get_random_column      ; Random column!
    sta OBJ_COL

    jsr draw_object
    rts

update_object:
    lda OBJ_ACTIVE
    beq done_update

    jsr erase_object

    inc OBJ_ROW

    lda OBJ_ROW
    cmp #24
    bne still_falling

    lda #$00
    sta OBJ_ACTIVE

    inc MISSES
    jsr display_misses
    jsr spawn_object
    rts

still_falling:
    jsr draw_object

done_update:
    rts

check_collision:
    lda OBJ_ACTIVE
    beq no_collision

    lda OBJ_ROW
    cmp #PLAYER_ROW
    bne no_collision

    lda OBJ_COL
    cmp PLAYER_COL
    bne no_collision

    jsr handle_catch

no_collision:
    rts

handle_catch:
    jsr erase_object

    lda #$00
    sta OBJ_ACTIVE

    inc SCORE
    jsr display_score

    jsr spawn_object
    rts

; Row offset lookup table (low bytes)
row_offset_lo:
    !byte <(0*40), <(1*40), <(2*40), <(3*40), <(4*40)
    !byte <(5*40), <(6*40), <(7*40), <(8*40), <(9*40)
    !byte <(10*40), <(11*40), <(12*40), <(13*40), <(14*40)
    !byte <(15*40), <(16*40), <(17*40), <(18*40), <(19*40)
    !byte <(20*40), <(21*40), <(22*40), <(23*40), <(24*40)

; Row offset lookup table (high bytes)
row_offset_hi:
    !byte >(0*40), >(1*40), >(2*40), >(3*40), >(4*40)
    !byte >(5*40), >(6*40), >(7*40), >(8*40), >(9*40)
    !byte >(10*40), >(11*40), >(12*40), >(13*40), >(14*40)
    !byte >(15*40), >(16*40), >(17*40), >(18*40), >(19*40)
    !byte >(20*40), >(21*40), >(22*40), >(23*40), >(24*40)

draw_object:
    ; Get row offset from table
    ldx OBJ_ROW
    lda row_offset_lo,x
    sta $fb
    lda row_offset_hi,x
    sta $fc

    ; Add column (with 16-bit carry handling)
    lda $fb
    clc
    adc OBJ_COL
    sta $fb
    bcc +
    inc $fc
+
    ; Add SCREEN_RAM base address
    lda $fb
    clc
    adc #<SCREEN_RAM
    sta $fb
    lda $fc
    adc #>SCREEN_RAM
    sta $fc

    ; Draw character
    ldy #0
    lda #OBJECT_CHAR
    sta ($fb),y

    ; Calculate COLOR_RAM address
    lda $fb
    clc
    adc #<(COLOR_RAM-SCREEN_RAM)
    sta $fb
    lda $fc
    adc #>(COLOR_RAM-SCREEN_RAM)
    sta $fc

    ; Draw color
    lda #OBJECT_COLOR
    sta ($fb),y
    rts

erase_object:
    ; Get row offset from table
    ldx OBJ_ROW
    lda row_offset_lo,x
    sta $fb
    lda row_offset_hi,x
    sta $fc

    ; Add column
    lda $fb
    clc
    adc OBJ_COL
    sta $fb
    bcc +
    inc $fc
+
    ; Add SCREEN_RAM base
    lda $fb
    clc
    adc #<SCREEN_RAM
    sta $fb
    lda $fc
    adc #>SCREEN_RAM
    sta $fc

    ; Erase with space
    ldy #0
    lda #$20
    sta ($fb),y
    rts

display_score:
    lda SCORE
    clc
    adc #$30
    sta SCREEN_RAM

    lda #WHITE
    sta COLOR_RAM
    rts

display_misses:
    lda MISSES
    clc
    adc #$30
    sta SCREEN_RAM + 5

    lda #WHITE
    sta COLOR_RAM + 5
    rts
