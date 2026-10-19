; BBC Model B MOS service. Keep the MOS IRQ path and interrupts enabled.
; OSBYTE &13 waits for the next display sync. A becomes &13; X/Y/flags change.
; ROM entry point, not a replacement IRQ handler. Reuses the system's clock.
OSBYTE = $fff4
wait_frame:
    lda #19
    jmp OSBYTE
