start:
        ; Enable interrupts (needed for HALT)
        im 1                    ; Interrupt mode 1
        ei                      ; Enable interrupts

        ; ... rest of setup ...
