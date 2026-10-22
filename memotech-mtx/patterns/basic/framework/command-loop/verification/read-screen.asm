; Verification only: snapshot the normal VS5 40x24 name table to CPU RAM.
; No rule state written. Called after CLS/PRINT, before INPUT.
; Owns $E000 code and $D000-$D3BF dump while verifying this bounded program.
    org $E000
    push af
    ld a,i
    push af
    di
    push bc
    push de
    push hl
    xor a
    out ($02),a
    ld a,$1C
    out ($02),a
    ld hl,$D000
    ld de,960
read_cell:
    in a,($01)
    ld (hl),a
    inc hl
    ld b,8
read_delay:
    djnz read_delay
    dec de
    ld a,d
    or e
    jr nz,read_cell
    pop hl
    pop de
    pop bc
    pop af
    jp po,no_ei
    ei
no_ei:
    pop af
    ret
