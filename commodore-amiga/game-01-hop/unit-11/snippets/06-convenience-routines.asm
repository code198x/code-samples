SFX_PERIOD_HOP      equ 300     ; Higher pitch
SFX_PERIOD_DEATH    equ 500     ; Lower pitch
SFX_PERIOD_SCORE    equ 250     ; Bright pitch
SFX_VOLUME          equ 64      ; Maximum volume

play_hop_sound:
            lea     sfx_hop,a0
            move.w  #SFX_HOP_LEN,d0
            move.w  #SFX_PERIOD_HOP,d1
            move.w  #SFX_VOLUME,d2
            bsr     play_sfx
            rts

play_death_sound:
            lea     sfx_death,a0
            move.w  #SFX_DEATH_LEN,d0
            move.w  #SFX_PERIOD_DEATH,d1
            move.w  #SFX_VOLUME,d2
            bsr     play_sfx
            rts

play_score_sound:
            lea     sfx_score,a0
            move.w  #SFX_SCORE_LEN,d0
            move.w  #SFX_PERIOD_SCORE,d1
            move.w  #SFX_VOLUME,d2
            bsr     play_sfx
            rts
