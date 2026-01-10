; Flash the "PRESS ANY KEY" prompt
; Called every frame during results state

flash_result_prompt:
        ; Increment frame counter
        ld a, (flash_counter)
        inc a
        ld (flash_counter), a

        ; Only toggle every 16 frames (~0.32 seconds at 50Hz)
        and %00001111
        ret nz                  ; Not time to toggle yet

        ; Toggle the flash state
        ld a, (flash_toggle)
        xor 1
        ld (flash_toggle), a

        ; Set prompt attributes based on toggle
        ld hl, ATTR_START + (RESULT_PROMPT_ROW * ATTR_WIDTH) + RESULT_PROMPT_COL
        ld b, 13                ; "PRESS ANY KEY" length

        ld a, (flash_toggle)
        or a
        jr z, prompt_yellow
        ld a, %00000111         ; White when flashed
        jr set_flash_attr
prompt_yellow:
        ld a, %00000110         ; Yellow normally

set_flash_attr:
        ld (hl), a
        inc hl
        djnz set_flash_attr
        ret
