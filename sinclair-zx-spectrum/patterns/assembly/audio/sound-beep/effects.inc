; ula_output is the caller's maintained byte: border in bits 0-2,
; MIC in bit 3. Include sound-beep.inc once beside these wrappers.
; Each wrapper requires DI and clobbers AF, B, D, H and L.
sound_success:
    ld      hl,$c810         ; H=200, sixteen cycles per note
success_note:
    ld      a,(ula_output)
    push    hl
    call    sound_beep
    pop     hl
    ld      a,h
    sub     16              ; 200,184,168,152,136,120,104,88
    ld      h,a
    cp      72
    jr      nz,success_note
    ret

sound_error:
    ld      hl,$5810         ; H=88, sixteen cycles per note
error_note:
    ld      a,(ula_output)
    push    hl
    call    sound_beep
    pop     hl
    ld      a,h
    add     a,16            ; 88,104,120,136,152,168,184,200
    ld      h,a
    cp      216
    jr      nz,error_note
    ret

sound_click:
    ld      a,(ula_output)
    ld      hl,$7f0c         ; H=127, twelve cycles
    jp      sound_beep       ; its RET returns to our caller
