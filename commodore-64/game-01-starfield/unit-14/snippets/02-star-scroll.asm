        ; --- Update stars ---
        ldx #$00
star_loop:
        jsr erase_star

        ; Check if star should move this frame
        cpx #$04
        bcc move_star           ; Close stars (0-3) always move

        ; Distant star — only move on odd frames
        lda frame_count
        and #$01
        beq skip_move           ; Even frame, don't move

move_star:
        inc star_row,x
        lda star_row,x
        cmp #25
        bcc skip_move

        ; Wrap to row 0
        lda #$00
        sta star_row,x

skip_move:
        jsr draw_star

        inx
        cpx #$08
        bne star_loop
