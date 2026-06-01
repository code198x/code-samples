; ------------------------------------------------
; Subroutine: spawn_enemy
; A = starting Y position, X = enemy index
; ------------------------------------------------
spawn_enemy:
        sta enemy_y_tbl,x

        ; Random X from raster
        lda $d012
        and #$7f
        clc
        adc #$30
        sta enemy_x_tbl,x

        ; Clear flash timer
        lda #$00
        sta flash_tbl,x

        ; Restore sprite colour to green
        ldy sprite_colour_off,x
        lda #$05
        sta $d000,y

        ; Update VIC-II sprite position
        ldy sprite_pos_off,x
        lda enemy_x_tbl,x
        sta $d000,y             ; Sprite X
        lda enemy_y_tbl,x
        sta $d001,y             ; Sprite Y (offset + 1)

        rts
