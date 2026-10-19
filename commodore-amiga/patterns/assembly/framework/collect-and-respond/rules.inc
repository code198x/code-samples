; Word state. Native joystick bits retained: U=$100 D=1 L=$200 R=2 Fire=$10.
; These rules change D0/D1/CCR; called from main only. Grid x=0..15,y=0..9.
detect_edges:
    move.w previous,d0
    not.w d0
    and.w controls,d0
    move.w d0,pressed
    move.w controls,d0
    not.w d0
    and.w previous,d0
    move.w d0,released
    move.w controls,previous
    rts
reset_game:
    move.w #2,player_x
    move.w #5,player_y
    move.w #1,item_active
    clr.w score
    clr.w move_delay
    rts
update_player:
    move.w pressed,d0
    and.w #$10,d0
    beq movement
    bsr reset_game
    rts
movement:
    tst.w move_delay
    beq move_now
    subq.w #1,move_delay
    rts
move_now:
    move.w #5,move_delay
    move.w controls,d0
    btst #9,d0
    beq move_right
    tst.w player_x
    beq move_right
    subq.w #1,player_x
move_right:
    btst #1,d0
    beq move_up
    cmp.w #15,player_x
    beq move_up
    addq.w #1,player_x
move_up:
    btst #8,d0
    beq move_down
    tst.w player_y
    beq move_down
    subq.w #1,player_y
move_down:
    btst #0,d0
    beq test_collection
    cmp.w #9,player_y
    beq test_collection
    addq.w #1,player_y
test_collection:
    tst.w item_active
    beq collection_done
    move.w player_x,d0
    move.w d0,rect_a
    addq.w #1,d0
    move.w d0,rect_a+4
    move.w player_y,d0
    move.w d0,rect_a+2
    addq.w #1,d0
    move.w d0,rect_a+6
    bsr boxes_overlap
    tst.w d0
    beq collection_done
    clr.w item_active
    addq.w #1,score
    bsr trigger_sound
collection_done:
    rts
