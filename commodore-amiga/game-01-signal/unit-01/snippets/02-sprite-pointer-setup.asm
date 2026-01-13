; Hardware Sprite Pointer Setup
; Sprites need their data address written to the copper list.
; The address is split into high and low words.

            ; --- Set sprite pointer in copper list ---
            lea     frog_data,a0        ; A0 = sprite data address
            move.l  a0,d0               ; D0 = sprite data address
            swap    d0                  ; High word first
            lea     sprpth_val,a1
            move.w  d0,(a1)             ; Write high word
            swap    d0                  ; Low word
            lea     sprptl_val,a1
            move.w  d0,(a1)             ; Write low word

; sprpth_val and sprptl_val are labels in the copper list
; where the high/low address words will be written.
