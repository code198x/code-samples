; Key handling for state transitions
; Two styles: blocking (wait_any_key) and non-blocking (check_any_key)

; Wait for any key press - blocking
; Used on title screen
wait_any_key:
        ; Wait for all keys to be released first
wait_release:
        xor a
        in a, (KEYBOARD_PORT)
        cp $FF
        jr nz, wait_release

        ; Now wait for a key press
wait_press:
        halt
        xor a
        in a, (KEYBOARD_PORT)
        cp $FF
        jr z, wait_press

        ret

; Check if any key is pressed - non-blocking
; Returns: Z flag set if no key, cleared if key pressed
; Used on results screen
check_any_key:
        xor a
        in a, (KEYBOARD_PORT)
        cp $FF
        ret                     ; Z set if $FF (no keys)
