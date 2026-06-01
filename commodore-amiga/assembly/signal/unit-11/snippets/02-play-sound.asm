; Play Sound Effect
; Select sound by number, configure Paula, trigger playback

; Sound effect numbers
SND_HOP         equ 0
SND_DEATH       equ 1
SND_HOME        equ 2

play_sound:
            ; Get sound data based on D0
            cmp.w   #SND_HOP,d0
            beq.s   .play_hop
            cmp.w   #SND_DEATH,d0
            beq.s   .play_death
            cmp.w   #SND_HOME,d0
            beq.s   .play_home
            rts

.play_hop:
            lea     sound_hop,a0
            move.w  #HOP_LEN/2,d1       ; Length in words
            move.w  #300,d2             ; Period (medium pitch)
            bra.s   .do_play

.play_death:
            lea     sound_death,a0
            move.w  #DEATH_LEN/2,d1
            move.w  #500,d2             ; Period (lower pitch)
            bra.s   .do_play

.play_home:
            lea     sound_home,a0
            move.w  #HOME_LEN/2,d1
            move.w  #200,d2             ; Period (higher pitch)

.do_play:
            ; Stop any playing sound first
            move.w  #$0001,DMACON(a5)   ; Disable AUD0

            ; Configure channel
            move.l  a0,AUD0LC(a5)       ; Sample pointer
            move.w  d1,AUD0LEN(a5)      ; Length in words
            move.w  d2,AUD0PER(a5)      ; Period (pitch)
            move.w  #64,AUD0VOL(a5)     ; Maximum volume

            ; Start playback
            move.w  #$8001,DMACON(a5)   ; Enable AUD0

            rts
