NUM_CREATURES       equ 5

            ; Creature 0: starts on platform
            move.w  #80,CR_X(a0)
            move.w  #92,CR_Y(a0)
            move.w  #CREATURE_SPEED,CR_DX(a0)
            move.w  #STATE_WALKING,CR_STATE(a0)
            move.w  #0,CR_STEP(a0)

            ; Creature 1: starts on left ground
            move.w  #16,CR_X+CR_SIZE(a0)
            move.w  #140,CR_Y+CR_SIZE(a0)
            move.w  #CREATURE_SPEED,CR_DX+CR_SIZE(a0)
            move.w  #STATE_WALKING,CR_STATE+CR_SIZE(a0)
            move.w  #4,CR_STEP+CR_SIZE(a0)

            ; Creature 2: starts on right ground
            move.w  #160,CR_X+CR_SIZE*2(a0)
            move.w  #108,CR_Y+CR_SIZE*2(a0)
            move.w  #CREATURE_SPEED,CR_DX+CR_SIZE*2(a0)
            move.w  #STATE_WALKING,CR_STATE+CR_SIZE*2(a0)
            move.w  #2,CR_STEP+CR_SIZE*2(a0)

            ; Creature 3: starts on left ground (staggered)
            move.w  #48,CR_X+CR_SIZE*3(a0)
            move.w  #140,CR_Y+CR_SIZE*3(a0)
            move.w  #CREATURE_SPEED,CR_DX+CR_SIZE*3(a0)
            move.w  #STATE_WALKING,CR_STATE+CR_SIZE*3(a0)
            move.w  #6,CR_STEP+CR_SIZE*3(a0)

            ; Creature 4: starts on right ground (staggered)
            move.w  #200,CR_X+CR_SIZE*4(a0)
            move.w  #108,CR_Y+CR_SIZE*4(a0)
            move.w  #CREATURE_SPEED,CR_DX+CR_SIZE*4(a0)
            move.w  #STATE_WALKING,CR_STATE+CR_SIZE*4(a0)
            move.w  #3,CR_STEP+CR_SIZE*4(a0)
