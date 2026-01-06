ai_think_delay:
        ld a, (difficulty)
        cp 1
        jr z, .easy
        cp 3
        jr z, .hard

        ; Normal
        ld b, 25
        jr .delay_loop

.easy:
        ld b, 40
        jr .delay_loop

.hard:
        ld b, 10

.delay_loop:
        halt
        djnz .delay_loop
        ret
