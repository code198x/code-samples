; ----------------------------------------------------------------------------
; Key Repeat Logic (in handle_input)
; ----------------------------------------------------------------------------
; Prevents rapid cursor movement when holding a key

handle_input:
            ld      a, (key_pressed)
            or      a
            jr      nz, .hi_have_key

            ; No key pressed - reset tracking
            xor     a
            ld      (last_key), a
            ld      (key_timer), a
            ret

.hi_have_key:
            ; Space (claim) always works immediately
            cp      5
            jr      z, try_claim

            ; Check if same key as last frame
            ld      b, a                    ; Save current key
            ld      a, (last_key)
            cp      b
            jr      nz, .hi_new_key

            ; Same key - check timer
            ld      a, (key_timer)
            or      a
            jr      z, .hi_allow            ; Timer expired, allow repeat
            dec     a
            ld      (key_timer), a
            ret                             ; Still waiting

.hi_new_key:
            ; New key pressed - save it and reset timer
            ld      a, b
            ld      (last_key), a
            ld      a, KEY_DELAY
            ld      (key_timer), a

.hi_allow:
            ; Process movement (cursor update code follows)
            ; ...
