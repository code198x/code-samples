; Debouncing: detect NEW key presses, not held keys
; Without this, holding a key would trigger every frame

prev_keys:  defb 0          ; Store previous frame's key state

read_keys:
        ; ... read all keys into E register ...

        ; Compare with previous state
        ld a, (prev_keys)   ; Get previous state
        cpl                 ; Invert it (1s become 0s)
        and e               ; AND with current state
        ; Result: only bits that are NEW this frame

        ; Save current state for next frame
        ld a, e
        ld (prev_keys), a

; How it works:
; Previous = 0, Current = 1: NOT(0) AND 1 = 1 (new press!)
; Previous = 1, Current = 1: NOT(1) AND 1 = 0 (held, ignore)
; Previous = 1, Current = 0: NOT(1) AND 0 = 0 (released, ignore)
