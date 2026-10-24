; SPDX-License-Identifier: MIT
; Land on a One-way Platform. Contiguous private bytes: LANDED, SNAP, ACTOR_X, ACTOR_W, PREV_BOTTOM, NEW_BOTTOM, PLATFORM_X, PLATFORM_W, PLATFORM_Y, DROP.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; A/X/flags change; Y and decimal mode survive. D=0 for binary arithmetic.
one_way_platform_init:
    lda #0
    sta LANDED
    sta SNAP
    sta ACTOR_X
    sta ACTOR_W
    sta PREV_BOTTOM
    sta NEW_BOTTOM
    sta PLATFORM_X
    sta PLATFORM_W
    sta PLATFORM_Y
    sta DROP
    rts
one_way_platform_step:
    lda #0
    sta LANDED
    lda NEW_BOTTOM
    sta SNAP
    lda DROP
    bne platform_done
    lda ACTOR_W
    beq platform_done
    lda PLATFORM_W
    beq platform_done
    lda PREV_BOTTOM
    cmp PLATFORM_Y
    bcc platform_new
    bne platform_done
platform_new:
    lda NEW_BOTTOM
    cmp PLATFORM_Y
    bcc platform_done
    lda PLATFORM_X
    clc
    adc PLATFORM_W
    bcs platform_actor_end
    cmp ACTOR_X
    bcc platform_done
    beq platform_done
platform_actor_end:
    lda ACTOR_X
    clc
    adc ACTOR_W
    bcs platform_land
    cmp PLATFORM_X
    bcc platform_done
    beq platform_done
platform_land:
    lda #1
    sta LANDED
    lda PLATFORM_Y
    sta SNAP
platform_done:
    rts
component_end:
