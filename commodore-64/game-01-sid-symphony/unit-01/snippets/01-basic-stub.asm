; BASIC stub - allows the program to run with LOAD"*",8,1 then RUN
* = $0801
                !byte $0c, $08      ; Pointer to next BASIC line
                !byte $0a, $00      ; Line number 10
                !byte $9e           ; SYS token
                !text "2064"        ; Address in decimal
                !byte $00           ; End of line
                !byte $00, $00      ; End of BASIC program

; Main program starts here
* = $0810
