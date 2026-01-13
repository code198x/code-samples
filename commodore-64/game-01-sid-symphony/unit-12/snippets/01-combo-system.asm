; ----------------------------------------------------------------------------
; Combo System - Track consecutive hits and calculate multiplier
; ----------------------------------------------------------------------------

; Combo settings
COMBO_TIER_2  = 10              ; 2x multiplier at 10 combo
COMBO_TIER_3  = 25              ; 3x multiplier at 25 combo
COMBO_TIER_4  = 50              ; 4x multiplier at 50 combo

; Variables
combo:        !byte 0           ; Current consecutive hits
max_combo:    !byte 0           ; Best combo this song

; ----------------------------------------------------------------------------
; Initialize Combo
; ----------------------------------------------------------------------------

init_combo:
            lda #0
            sta combo
            sta max_combo
            jsr display_combo
            rts

; ----------------------------------------------------------------------------
; Get Multiplier - Returns 1-4 based on current combo
; ----------------------------------------------------------------------------

get_multiplier:
            lda combo
            cmp #COMBO_TIER_4
            bcs mult_4x
            cmp #COMBO_TIER_3
            bcs mult_3x
            cmp #COMBO_TIER_2
            bcs mult_2x

            ; Default: 1x
            lda #1
            rts

mult_2x:
            lda #2
            rts

mult_3x:
            lda #3
            rts

mult_4x:
            lda #4
            rts

; ----------------------------------------------------------------------------
; Increment Combo - Called on every successful hit
; ----------------------------------------------------------------------------

increment_combo:
            inc combo

            ; Update max combo if this is the best
            lda combo
            cmp max_combo
            bcc combo_not_max
            sta max_combo
combo_not_max:

            jsr display_combo
            rts

; ----------------------------------------------------------------------------
; Break Combo - Called on every miss
; ----------------------------------------------------------------------------

break_combo:
            lda combo
            beq combo_already_zero

            ; Reset combo to zero
            lda #0
            sta combo
            jsr display_combo

combo_already_zero:
            rts
