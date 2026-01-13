; ----------------------------------------------------------------------------
; Wait For Key
; ----------------------------------------------------------------------------
; Waits until any key is pressed

wait_for_key:
            ; First wait for all keys to be released
.wfk_release:
            xor     a
            in      a, (KEY_PORT)
            cpl                     ; Invert (keys are active low)
            and     %00011111       ; Mask to key bits
            jr      nz, .wfk_release

            ; Now wait for a key press
.wfk_wait:
            halt                    ; Wait for interrupt
            xor     a
            in      a, (KEY_PORT)
            cpl
            and     %00011111
            jr      z, .wfk_wait

            ret
