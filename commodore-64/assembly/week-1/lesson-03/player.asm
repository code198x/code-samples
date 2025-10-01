; SKYFALL - Lesson 3
; Drawing the player character

* = $0801

; BASIC stub: SYS 2061
!byte $0c,$08,$0a,$00,$9e
!byte $32,$30,$36,$31          ; "2061" in ASCII
!byte $00,$00,$00

* = $080d

; Constants
SCREEN_RAM = $0400
COLOR_RAM = $d800
PLAYER_CHAR = $1e              ; Upward wedge
PLAYER_COLOR = $01             ; White
PLAYER_ROW = 23
PLAYER_COL = 20

main:
    ; Calculate screen position: row 23, column 20
    ; Address = $0400 + (23 * 40) + 20 = $0400 + 920 + 20 = $0798 + 20 = $07AC

    lda #PLAYER_CHAR
    sta SCREEN_RAM + (PLAYER_ROW * 40) + PLAYER_COL

    lda #PLAYER_COLOR
    sta COLOR_RAM + (PLAYER_ROW * 40) + PLAYER_COL

    rts
