; SKYFALL - Lesson 2, Sample 1
; Single character in screen memory

* = $0801

; BASIC stub: SYS 2061
!byte $0c,$08,$0a,$00,$9e
!byte $32,$30,$36,$31          ; "2061" in ASCII
!byte $00,$00,$00

* = $080d

main:
    lda #$51                   ; Character code for Q
    sta $0400                  ; Top-left corner of screen
    rts
