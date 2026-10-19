; Wait for the next low-to-high transition of raster bit 8.
; Own no IRQ source. Flags change; A/X/Y survive. I/O must be visible.
; Both phases matter: a quick caller cannot consume the same boundary twice.
wait_frame:
    bit $d011
    bmi wait_frame
wait_frame_high:
    bit $d011
    bpl wait_frame_high
    rts
