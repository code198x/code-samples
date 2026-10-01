    org     32768
start:
    di
    ld      sp,$ff00
    call    pause           ; let the browser audio output start before the first tone
    ld      a,(ula_output)
    ld      hl,$ff69         ; H=255, 105 cycles: about 524 Hz for 200 ms
    call    sound_beep
    call    pause
    call    sound_success
    call    pause
    call    sound_error
    call    pause
    call    sound_click
    ld      a,1
    ld      (done),a
    ei
finished:
    halt
    jr      finished

; Half a second between sounds, using the stock 48K ROM interrupt.
pause:
    ld      b,25
pause_frame:
    ei
    halt
    di
    djnz    pause_frame
    ret

    include "sound-beep.inc"
    include "effects.inc"
ula_output:
    defb    1               ; blue border, MIC low
done:
    defb    0
    end     start
