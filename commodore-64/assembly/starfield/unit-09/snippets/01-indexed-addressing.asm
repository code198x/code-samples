        ; --- Update all enemies ---
        ldx #$00
enemy_loop:
        lda flash_tbl,x
        bne do_flash

        ; Move down 1 pixel per frame
        lda enemy_y_tbl,x
        clc
        adc #$01
        sta enemy_y_tbl,x

        ; Off-screen check (Y >= 248)
        cmp #$f8
        bcc update_sprite

        ; Respawn at top
        lda #$32
        jsr spawn_enemy
        jmp next_enemy

do_flash:
        dec flash_tbl,x
        bne update_sprite       ; Still flashing

        ; Flash done — respawn
        lda #$32
        jsr spawn_enemy
        jmp next_enemy

update_sprite:
        ; Copy position to VIC-II
        ldy sprite_pos_off,x
        lda enemy_x_tbl,x
        sta $d000,y
        lda enemy_y_tbl,x
        sta $d001,y

next_enemy:
        inx
        cpx #$03
        bne enemy_loop
