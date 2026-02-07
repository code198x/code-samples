; In the main loop: wait for NMI to signal a new frame
main_loop:
    lda nmi_flag            ; Has a new frame started?
    beq main_loop           ; No — keep waiting
    lda #0
    sta nmi_flag            ; Clear the flag

    ; ... game logic runs here, once per frame ...

    jmp main_loop

; In the NMI handler: set the flag after OAM DMA
nmi:
    ; ... save registers, do OAM DMA ...
    lda #1
    sta nmi_flag            ; Signal the main loop
    ; ... restore registers ...
    rti
