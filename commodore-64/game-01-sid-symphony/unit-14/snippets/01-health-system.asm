; Health system constants
;
; Health is a single byte (0-64) representing player performance.
; Higher = better. Zero = game over.

HEALTH_MAX      = 64            ; Maximum health
HEALTH_START    = 32            ; Starting health (50%)
HEALTH_HIT      = 2             ; Health gained per hit
HEALTH_MISS     = 4             ; Health lost per miss

; Health bar characters (custom graphics)
HEALTH_FULL     = 131           ; Solid block for filled segment
HEALTH_EMPTY    = 132           ; Hollow block for empty segment

; Variables
health:         !byte 0         ; Current health (0-64)
game_over:      !byte 0         ; Flag: 1 = game has ended

; In init:
                lda #HEALTH_START
                sta health
                lda #0
                sta game_over
