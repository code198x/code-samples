; ----------------------------------------------------------------------------
; Health Settings
; ----------------------------------------------------------------------------

HEALTH_MAX    = 64              ; Maximum health
HEALTH_START  = 32              ; Starting health (half)
HEALTH_PERFECT = 4              ; Health gained on perfect hit
HEALTH_GOOD   = 2               ; Health gained on good hit
HEALTH_MISS   = 8               ; Health lost on miss

; ----------------------------------------------------------------------------
; Initialize Health
; ----------------------------------------------------------------------------

init_health:
            lda #HEALTH_START
            sta health
            jsr display_health
            rts

; ----------------------------------------------------------------------------
; Decrease Health - Subtract HEALTH_MISS, clamp at 0
; ----------------------------------------------------------------------------

decrease_health:
            lda health
            sec
            sbc #HEALTH_MISS
            bcc health_zero     ; Underflow - set to 0
            sta health
            jsr display_health
            jsr check_game_over
            rts

health_zero:
            lda #0
            sta health
            jsr display_health
            jsr check_game_over
            rts

; ----------------------------------------------------------------------------
; Increase Health - Add amount, clamp at HEALTH_MAX
; Input: A = amount to add
; ----------------------------------------------------------------------------

increase_health:
            clc
            adc health
            cmp #HEALTH_MAX
            bcc health_ok
            lda #HEALTH_MAX     ; Clamp to max
health_ok:
            sta health
            jsr display_health
            rts
