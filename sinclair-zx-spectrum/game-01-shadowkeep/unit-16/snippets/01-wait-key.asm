; wait_key — wait for a keypress (with debounce)
;
; XOR A sets A to 0. When used as the port address high byte,
; this selects ALL keyboard rows at once. The result is the
; AND of all rows — a bit is 0 if ANY key in that column is
; pressed across any row.
;
; Keys are active low: $1F (all bits high) means nothing pressed.
; Anything less means at least one key is down.

wait_key:
            ; Wait for all keys to be released first
.release:   halt
            xor     a               ; A = 0 → address $00FE (all rows)
            in      a, ($fe)
            and     $1f             ; Mask to 5 key bits
            cp      $1f             ; $1F = no keys pressed
            jr      nz, .release    ; Key still held — wait

            ; Now wait for any key to be pressed
.press:     halt
            xor     a
            in      a, ($fe)
            and     $1f
            cp      $1f
            jr      z, .press       ; No key — keep waiting
            ret
