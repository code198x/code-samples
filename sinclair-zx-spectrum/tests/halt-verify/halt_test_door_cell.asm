;
; HALT verification — H3 (the DOOR-cell mystery).
;
; Same minimal HALT loop as halt_test.asm, but with $28 (DOOR_OPEN cell)
; written to $593A (the attribute address used in Shadowkeep U5/U6).
;
; Brief said: "Remove that one byte and rate-limit works again." If H3 was
; H2 in disguise, this will show identical clean single-OUT-per-frame
; behaviour. If H3 is a separate bug, we'll see stripes.
;

            org     32768

start:
            im      1
            ei

            xor     a
            out     ($FE), a            ; clear border

            ld      a, $28              ; DOOR_OPEN: PAPER 5 cyan, no BRIGHT, no FLASH
            ld      ($593A), a          ; the attribute address from Shadowkeep U5/U6

main_loop:
            halt
            ld      a, (debug_b)
            xor     7
            ld      (debug_b), a
            out     ($FE), a
            jr      main_loop

debug_b:    defb    0

            end     start
