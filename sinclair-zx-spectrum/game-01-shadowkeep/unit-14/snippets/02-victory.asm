; Victory sequence — sound, message, halt
;
; The game leaves the main loop permanently. A four-note
; fanfare plays, the score line shows ROOM COMPLETE!, and
; the program enters an infinite halt loop. The game is over.

.room_complete:
            ; Victory fanfare — four ascending notes
            ld      hl, 100
            ld      e, 45               ; Low
            call    beep
            ld      hl, 100
            ld      e, 35               ; Mid
            call    beep
            ld      hl, 100
            ld      e, 25               ; High
            call    beep
            ld      hl, 300
            ld      e, 18               ; Sustained high
            call    beep

            ; Overwrite score line with victory message
            ld      de, SCORE_SCR
            ld      hl, win_text
            call    print_str

            ; Green border — permanent
            ld      a, 4
            out     ($fe), a

            ; Halt forever
.victory:   halt
            jr      .victory
