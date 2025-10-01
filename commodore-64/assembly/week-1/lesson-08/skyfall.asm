; SKYFALL - Lesson 8
; Responsive controls

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

BLACK = $00
WHITE = $01
DARK_GREY = $0b

PLAYER_CHAR = $1e
PLAYER_COLOR = WHITE
PLAYER_ROW = 23
PLAYER_START_COL = 20

; Variables
PLAYER_COL = $02
MOVE_COUNTER = $03

; ===================================
; Main Program
; ===================================
main:
    jsr init_screen

    lda #PLAYER_START_COL
    sta PLAYER_COL

    lda #3
    sta MOVE_COUNTER

    jsr draw_player

game_loop:
    jsr wait_for_raster

    dec MOVE_COUNTER
    bne skip_movement

    lda #3
    sta MOVE_COUNTER
    jsr check_keys

skip_movement:
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
    ; Check D key first (column 2)
    lda #%11111011
    sta CIA1_PORT_B
    lda CIA1_PORT_A
    sta $fb                    ; Save key state

    ; Check D key first (right has priority)
    and #%00000100
    beq move_right

    ; Check A key (column 1)
    lda #%11111101
    sta CIA1_PORT_B
    lda CIA1_PORT_A
    and #%00000100
    beq move_left

    ; Neither key pressed
    rts

move_left:
    lda PLAYER_COL
    beq skip_left

    jsr erase_old_player
    dec PLAYER_COL
    jsr draw_player

skip_left:
    rts

move_right:
    lda PLAYER_COL
    cmp #39
    beq skip_right

    jsr erase_old_player
    inc PLAYER_COL
    jsr draw_player

skip_right:
    rts

erase_old_player:
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
