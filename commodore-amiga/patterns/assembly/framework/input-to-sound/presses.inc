; Call once after read_controls. Clobbers D0/D1/CCR; preserves other registers.
; Initialise previous_controls to zero, or seed from controls on scene entry.
detect_presses:
    move.w previous_controls,d1
    not.w d1
    move.w controls,d0
    and.w d0,d1
    move.w d1,new_presses
    move.w d0,previous_controls
    rts
previous_controls: dc.w 0
new_presses: dc.w 0
