; Pulse 1 only. $4015 is owned by this caller; DMC remains disabled.
; Non-blocking eight-frame effect. service_sound precedes update_player.
trigger_sound:
    lda #1
    sta $4015
    lda #$d5
    ldx #0
    jsr pulse1_tone
    lda #8
    sta sound_ticks
    rts
service_sound:
    lda sound_ticks
    beq sound_done
    dec sound_ticks
    bne sound_done
    lda #0
    sta $4015
sound_done:
    rts
map_controls:
    lda controls
    sta raw_controls
    lda #0
    sta controls
    ldx #4
map_button:
    lda raw_controls
    and raw_masks,x
    beq map_next
    lda controls
    ora game_masks,x
    sta controls
map_next:
    dex
    bpl map_button
    rts
raw_masks: .byte 8,4,2,1,$80
game_masks: .byte 1,2,4,8,16
