; Debounced key reading - detect NEW presses only
;
; Problem: Reading a key shows "pressed" for many frames while held.
; We only want to trigger once per press.
;
; Solution: Track key state. Only set "pressed" when transitioning
; from "not held" to "held".

scan_keyboard:
                ; Clear pressed flags (these are per-frame events)
                lda #0
                sta key_x_pressed
                sta key_c_pressed
                sta key_v_pressed

                ; --- Check X key ---
                lda #KEY_X_COL
                sta KEYBOARD_COLUMN
                lda KEYBOARD_ROW
                and #KEY_X_ROW
                bne .x_not_pressed

                ; X is physically pressed - check if NEW
                lda key_x_state
                bne .x_done             ; Already held, ignore
                lda #1
                sta key_x_pressed       ; New press this frame!
                sta key_x_state         ; Remember it's held
                jmp .x_done

.x_not_pressed:
                lda #0
                sta key_x_state         ; Not held anymore

.x_done:
                ; ... repeat for C and V keys ...
                rts
