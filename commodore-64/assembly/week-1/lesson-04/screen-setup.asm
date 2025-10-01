; SKYFALL - Lesson 4
; Screen setup and subroutines

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

BLACK = $00
WHITE = $01
DARK_GREY = $0b

PLAYER_CHAR = $1e
PLAYER_COLOR = WHITE
PLAYER_ROW = 23
PLAYER_COL = 20

; ===================================
; Main Program
; ===================================
main:
    jsr init_screen
    jsr draw_player
    rts

; ===================================
; Subroutines
; ===================================

init_screen:
    lda #BLACK
    sta VIC_BACKGROUND
    lda #DARK_GREY
    sta VIC_BORDER
    jsr clear_screen
    rts

clear_screen:
    lda #$20                   ; Space character
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

draw_player:
    lda #PLAYER_CHAR
    sta SCREEN_RAM + (PLAYER_ROW * 40) + PLAYER_COL

    lda #PLAYER_COLOR
    sta COLOR_RAM + (PLAYER_ROW * 40) + PLAYER_COL
    rts
