; SKYFALL - Lesson 1
; Hello, Assembly!

* = $0801

; BASIC stub: SYS 2061
!byte $0c,$08,$0a,$00,$9e
!byte $32,$30,$36,$31          ; "2061" in ASCII
!byte $00,$00,$00

* = $080d

; Main program
main:
    lda #$02                   ; Load red color
    sta $d020                  ; Store in border register
    rts                        ; Return
