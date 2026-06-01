; ----------------------------------------------------------------------------
; Check Keys
; ----------------------------------------------------------------------------
; Reads keyboard and triggers sounds for Z, X, C keys

check_keys:
            ; Check Z key (row 1, column 2)
            ; Z is at keyboard matrix position: row=$FD (bit 1 low), col=$10 (bit 4)
            lda #$FD            ; Select row 1 (bit 1 = 0)
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10            ; Check column 4 (Z key)
            bne +               ; Branch if not pressed
            jsr play_voice1
            jsr flash_track1
+
            ; Check X key (row 2, column 7)
            ; X is at keyboard matrix position: row=$FB (bit 2 low), col=$80 (bit 7)
            lda #$FB            ; Select row 2 (bit 2 = 0)
            sta CIA1_PRA
            lda CIA1_PRB
            and #$80            ; Check column 7 (X key)
            bne +               ; Branch if not pressed
            jsr play_voice2
            jsr flash_track2
+
            ; Check C key (row 2, column 4)
            ; C is at keyboard matrix position: row=$FB (bit 2 low), col=$10 (bit 4)
            lda #$FB            ; Select row 2 (bit 2 = 0)
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10            ; Check column 4 (C key)
            bne +               ; Branch if not pressed
            jsr play_voice3
            jsr flash_track3
+
            ; Reset keyboard scanning
            lda #$FF
            sta CIA1_PRA

            rts
