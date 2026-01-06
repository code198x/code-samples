lda buttons
    and #BTN_UP         ; Isolate the up bit
    beq @not_up         ; Zero means not pressed
    ; Handle up...
@not_up:
