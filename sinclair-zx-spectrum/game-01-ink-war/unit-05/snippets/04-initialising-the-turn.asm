start:
        ; ... clear screen, draw board, highlight cursor ...

        ; Set initial turn indicator
        call update_ui_colours

        ; Set up interrupts for timing
        im 1
        ei

        ; Main loop
main_loop:
        ; ...
