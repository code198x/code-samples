; ============================================================================
; PRIMER — Beat 3: Everything Is a Number
; ============================================================================
; A register holds a byte: a number from 0 to 255. That's all it holds. It
; does NOT hold a "letter" or a "colour" or a "pixel pattern" — those are just
; things we decide a number means. The byte has no type; meaning is whatever
; you choose to DO with it.
;
; To prove the machine doesn't know a letter from a number, we load the
; LETTER 'A' — and the register just fills with 65. Because that's what 'A'
; is: the number 65. These four lines would ALL put the same byte in A:
;
;       ld a, 65            ; decimal
;       ld a, $41           ; hex      ($ means hex; $41 = 65)
;       ld a, 'A'           ; a letter (the machine sees its code, 65)
;       ld a, %01000001     ; binary   (a row of bits — also a pixel pattern!)
;
; All four are the byte $41. Open the register view and you'll see A = $41
; (65) however you wrote it. We use the letter here because it's the most
; surprising: a "letter" was a number all along.
; ============================================================================

            org     32768

start:
            ld      a, 'A'           ; load the LETTER 'A' — to the CPU, just 65
            out     ($FE), a         ; show it on the border (65 -> low 3 bits = 1 = blue)

.loop:
            halt
            jr      .loop

            end     start
