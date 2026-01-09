SCALE_LENGTH    = 8                 ; 8 notes (C4 to C5)

main_loop:
                ; --- Ascending: C D E F G A B C ---
                ldx #0              ; Start at index 0 (C4)
.ascending:
                jsr play_note       ; Play note at index X
                inx                 ; Next note
                cpx #SCALE_LENGTH   ; Reached the end?
                bne .ascending      ; No - keep going

                ; --- Descending: B A G F E D C ---
                ldx #SCALE_LENGTH - 2   ; Start at index 6 (B4)
.descending:
                jsr play_note
                dex                 ; Previous note
                bpl .descending     ; Continue while X >= 0

                jmp main_loop       ; Repeat forever
