    ; --- Collision with obstacle ---
    lda hurt_timer          ; the grace window: fresh from a respawn,
    bne @no_collide         ; nothing can hurt you while you find your feet
    lda on_ground
    beq @no_collide

    ; --- Check for hazard tiles ---
    lda hurt_timer          ; the grace window covers the spikes too
    beq @hazard_check
    dec hurt_timer          ; (and this is where it counts down)
    jmp @no_hazard
@hazard_check:
    lda on_ground
