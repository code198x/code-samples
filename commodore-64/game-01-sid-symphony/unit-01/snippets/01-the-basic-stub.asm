* = $0801

; BASIC stub: 10 SYS 2064
            !byte $0c, $08      ; Pointer to next BASIC line
            !byte $0a, $00      ; Line number 10
            !byte $9e           ; SYS token
            !byte $32, $30, $36, $34  ; "2064" in PETSCII
            !byte $00           ; End of line
            !byte $00, $00      ; End of program
