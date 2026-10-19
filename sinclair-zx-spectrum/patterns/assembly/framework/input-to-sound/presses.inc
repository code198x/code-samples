; Call after read_controls, once per update. AF/B change; other registers survive.
; Initialise previous_controls to zero, or seed it with controls on scene entry.
detect_presses:
    ld a,(previous_controls)
    cpl
    ld b,a
    ld a,(controls)
    and b
    ld (new_presses),a
    ld a,(controls)
    ld (previous_controls),a
    ret
previous_controls: defb 0
new_presses: defb 0
