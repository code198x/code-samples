; SKYFALL - Lesson 2, Sample 2
; Character in the middle of the screen

* = $0801

; BASIC stub: SYS 2061
!byte $0c,$08,$0a,$00,$9e
!byte $32,$30,$36,$31          ; "2061" in ASCII
!byte $00,$00,$00

* = $080d

main:
    lda #$51                   ; Character code for Q
    sta $05f4                  ; Row 12, column 20 (middle of screen)
    rts
