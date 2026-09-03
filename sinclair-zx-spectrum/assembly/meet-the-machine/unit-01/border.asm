; Meet the Machine - Unit 1: Assemble and Run
; Assemble with: asm198x --dialect pasmonext --tapbas border.asm -o primer.tap

            org     32768

start:
            ld      a, 2            ; 2 is red
            out     ($FE), a        ; $FE is the border

.loop:
            halt                    ; wait for the next interrupt
            jr      .loop           ; then wait for the one after

            end     start
