; SKYFALL - Lesson 5
; Reading the keyboard

* = $0801

; BASIC stub: SYS 2061
!byte $0c,$08,$0a,$00,$9e
!byte $32,$30,$36,$31          ; "2061" in ASCII
!byte $00,$00,$00

* = $080d

; ===================================
; Constants
; ===================================
VIC_BORDER = $d020
CIA1_PORT_A = $dc01
CIA1_PORT_B = $dc00

BLACK = $00
RED = $02
CYAN = $03

; ===================================
; Main Program
; ===================================
main:
    lda #BLACK
    sta VIC_BORDER

game_loop:
    jsr check_a_key
    jsr check_d_key
    jmp game_loop

; ===================================
; Subroutines
; ===================================

check_a_key:
    lda #%11111101             ; Select column 1
    sta CIA1_PORT_B
    lda CIA1_PORT_A
    and #%00000100             ; Check bit 2
    beq a_is_pressed
    rts

a_is_pressed:
    lda #RED
    sta VIC_BORDER
    rts

check_d_key:
    lda #%11111011             ; Select column 2
    sta CIA1_PORT_B
    lda CIA1_PORT_A
    and #%00000100             ; Check bit 2
    beq d_is_pressed
    rts

d_is_pressed:
    lda #CYAN
    sta VIC_BORDER
    rts
