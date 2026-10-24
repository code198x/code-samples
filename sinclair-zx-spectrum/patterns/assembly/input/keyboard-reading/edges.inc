; Call after read_controls once per update, alongside the maintained presses.inc.
; AF/BC change; DE/HL/IX/IY survive. One private released byte.
detect_control_edges:
    ld a,(previous_controls)
    ld (released_controls),a
    call detect_presses
    ld a,(controls)
    ld b,a
    ld a,(released_controls)
    call release_bits
    ld (released_controls),a
    ret
; Pure entry: A=previous, B=current normalised five-bit masks.
; A=released; B/DE/HL/IX/IY survive. C/flags change.
release_bits:
    ld c,a
    ld a,b
    cpl
    and c
    ret
edges_code_end:
released_controls: defb 0
