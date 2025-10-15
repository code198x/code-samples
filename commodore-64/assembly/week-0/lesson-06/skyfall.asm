; SKYFALL - Lesson 6
; Moving the player

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
VIC_RASTER = $d012
CIA1_PORT_A = $dc01
CIA1_PORT_B = $dc00

BLACK = $00
WHITE = $01
DARK_GREY = $0b

PLAYER_CHAR = $1e
PLAYER_COLOR = WHITE
PLAYER_ROW = 23
PLAYER_START_COL = 20

; Variables
PLAYER_COL = $02               ; Current column (0-39)

; ===================================
; Main Program
; ===================================
main:
    jsr init_screen

    lda #PLAYER_START_COL
    sta PLAYER_COL

    jsr draw_player

game_loop:
    jsr wait_for_raster        ; Sync to screen refresh
    jsr check_keys
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
    jsr check_a_key
    jsr check_d_key
    rts

check_a_key:
    lda #%11111101
    sta CIA1_PORT_B
    lda CIA1_PORT_A
    and #%00000100
    beq move_left
    rts

move_left:
    lda PLAYER_COL
    beq skip_left              ; At left edge already?

    jsr erase_old_player
    dec PLAYER_COL
    jsr draw_player

skip_left:
    rts

check_d_key:
    lda #%11111011
    sta CIA1_PORT_B
    lda CIA1_PORT_A
    and #%00000100
    beq move_right
    rts

move_right:
    lda PLAYER_COL
    cmp #39                    ; At right edge already?
    beq skip_right

    jsr erase_old_player
    inc PLAYER_COL
    jsr draw_player

skip_right:
    rts

erase_old_player:
    ldx PLAYER_COL
    lda #$20                   ; Space
    sta SCREEN_RAM + (PLAYER_ROW * 40),x
    rts

draw_player:
    ldx PLAYER_COL
    lda #PLAYER_CHAR
    sta SCREEN_RAM + (PLAYER_ROW * 40),x

    lda #PLAYER_COLOR
    sta COLOR_RAM + (PLAYER_ROW * 40),x
    rts
