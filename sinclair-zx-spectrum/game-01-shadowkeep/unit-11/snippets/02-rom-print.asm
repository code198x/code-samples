; Print to the screen using Spectrum ROM routines.

            ; Open channel 2 (upper screen)
            ld      a, 2
            call    $1601               ; CHAN-OPEN

            ; Position cursor at row 23, column 10
            ld      a, 22               ; AT control code
            rst     $10
            ld      a, 23               ; Row
            rst     $10
            ld      a, 10               ; Column
            rst     $10

            ; Print a character
            ld      a, 'T'              ; ASCII character
            rst     $10                 ; Output to screen

            ; Convert number to ASCII and print
            ld      a, (treasure_count) ; 0-9
            add     a, '0'              ; Add 48 — ASCII '0'
            rst     $10
