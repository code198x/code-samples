; ----------------------------------------------------------------------------
; Random Number Generation
; ----------------------------------------------------------------------------
; Uses Z80's R register which increments with each instruction

get_random:
            ld      a, r            ; R register changes every instruction
            ld      b, a
            ld      a, (random_seed)
            add     a, b
            rlca                    ; Rotate left
            xor     b               ; Mix bits
            ld      (random_seed), a
            ret

random_seed:    defb    $5a         ; Seed value
