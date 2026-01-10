; Variables for prompt flashing animation

flash_toggle:   defb 0          ; Current flash state (0 or 1)
flash_counter:  defb 0          ; Frame counter for timing

; Reset in enter_results_state:
;   xor a
;   ld (flash_toggle), a
;   ld (flash_counter), a
