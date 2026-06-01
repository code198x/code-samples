            ; Update sprites for all 5 creatures
            lea     creatures,a2
            lea     sprite0_data,a0
            bsr     write_sprite_pos

            lea     creatures+CR_SIZE,a2
            lea     sprite1_data,a0
            bsr     write_sprite_pos

            lea     creatures+CR_SIZE*2,a2
            lea     sprite2_data,a0
            bsr     write_sprite_pos

            lea     creatures+CR_SIZE*3,a2
            lea     sprite3_data,a0
            bsr     write_sprite_pos

            lea     creatures+CR_SIZE*4,a2
            lea     sprite4_data,a0
            bsr     write_sprite_pos
