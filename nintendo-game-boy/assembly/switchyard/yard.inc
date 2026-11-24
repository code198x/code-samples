; Switchyard: original DMG/MBC0 cartridge. Inputs and backgrounds only.
rJOYP EQU $FF00
rLCDC EQU $FF40
rSCY  EQU $FF42
rSCX  EQU $FF43
rLY   EQU $FF44
rBGP  EQU $FF47
TileMap EQU $9800

Route EQU $C000            ; 0 = lower branch, 1 = upper branch
Previous EQU $C001         ; positive-logic Start/B/A sample
Result EQU $C002           ; 0 = ready, 1 = delivered, 2 = missed

Track EQU 1
Arrow EQU 2
Target EQU 3
Parcel EQU 4
Check EQU 5
Cross EQU 6
BendUp EQU 7
Fork EQU 8
BendDown EQU 9
UpperGate EQU TileMap+8*32+9
LowerGate EQU TileMap+10*32+9
UpperDepot EQU TileMap+8*32+15
LowerDepot EQU TileMap+10*32+15
Home EQU TileMap+9*32+4
Feedback EQU TileMap+13*32+9

SECTION "Entry", ROM0[$100]
    nop
    jp start
    ds $134-@,0
    db "SWITCHYARD"
    ds $150-@,0

SECTION "Program", ROM0[$150]
start:
    di
    ld sp,$fffe
.wait_to_disable:
    ld a,[rLY]
    cp 144
    jr c,.wait_to_disable
    xor a
    ld [rLCDC],a
    ld [rSCY],a
    ld [rSCX],a
    ld [Previous],a
    ld [Result],a
    ld [Route],a
IF CHECKPOINT == 1
    ; Static first scene: make the tile edit visible before adding input.
    inc a
    ld [Route],a
ENDC

    ld hl,TileMap
    ld bc,32*32
.clear_map:
    xor a
    ld [hl+],a
    dec bc
    ld a,b
    or c
    jr nz,.clear_map

    ld hl,$8000
    ld de,tiles
    ld b,tiles_end-tiles
.copy_tiles:
    ld a,[de]
    ld [hl+],a
    inc de
    dec b
    jr nz,.copy_tiles

    ; The upper and lower horizontal tracks feed a shared junction.
    ld hl,TileMap+8*32+7
    call branch_track
    ld hl,TileMap+10*32+7
    call branch_track
    ld hl,TileMap+9*32+4
    ld a,Track
    ld [hl+],a
    ld [hl+],a
    ld [hl+],a
    ld [hl],a

    ld a,BendUp
    ld [TileMap+8*32+7],a
    ld a,Fork
    ld [TileMap+9*32+7],a
    ld a,BendDown
    ld [TileMap+10*32+7],a

    call draw
    ld a,$ec                ; map our ink (colour index 1) to black
    ld [rBGP],a
    ld a,$91
    ld [rLCDC],a
frame:
    call wait_frame
IF CHECKPOINT > 1
    call new_presses
    ld b,a
IF CHECKPOINT == 3
    ld a,[Result]
    and a
    jr z,.ready
    bit 1,b                  ; B operates only after the outcome.
    jr z,.redraw
    xor a
    ld [Route],a
    ld [Result],a
    jr .redraw
.ready:
ENDC
    bit 0,b                  ; A flips which path the parcel will take.
    jr z,.after_switch
    ld a,[Route]
    xor 1
    ld [Route],a
.after_switch:
IF CHECKPOINT == 3
    bit 3,b                  ; Start commits the currently selected path.
    jr z,.redraw
    ld a,[Route]
    xor 1
    inc a
    ld [Result],a
.redraw:
ENDC
    call draw
ENDC
    jr frame

; Start/B/A are sampled together, originally active low. Always store
; the current sample, including release; a held button is not a new press.
new_presses:
    ld a,$10
    ld [rJOYP],a
    ld a,[rJOYP]
    ld a,[rJOYP]
    ld a,[rJOYP]
    ld a,[rJOYP]
    ld a,[rJOYP]
    ld a,[rJOYP]
    cpl
    and %1011
    ld c,a
    ld a,[Previous]
    cpl
    and c
    ld b,a
    ld a,c
    ld [Previous],a
    ld a,b
    ret

wait_frame:
    ld a,[rLY]
    cp 144
    jr nc,wait_frame
.wait_vblank:
    ld a,[rLY]
    cp 144
    jr c,.wait_vblank
    ret

branch_track:
    ld b,9
    ld a,Track
.fill:
    ld [hl+],a
    dec b
    jr nz,.fill
    ret

; Call only with LCD off or at the start of VBlank. This updates six
; cells, leaving the authored tracks alone. No sprite DMA or interrupts.
draw:
    ld a,Track
    ld [UpperGate],a
    ld [LowerGate],a
    ld [LowerDepot],a
    ld [Home],a
    ld a,Target
    ld [UpperDepot],a
    xor a
    ld [Feedback],a

    ld a,[Route]
    and a
    jr z,.lower
    ld a,ROUTE_UP_TILE
    ld [UpperGate],a
    jr .place_parcel
.lower:
    ld a,Arrow
    ld [LowerGate],a
.place_parcel:
    ld a,[Result]
    and a
    jr z,.home
    cp 1
    jr nz,.missed
    ld a,Parcel
    ld [UpperDepot],a
    ld a,Check
    ld [Feedback],a
    ret
.missed:
    ld a,Parcel
    ld [LowerDepot],a
    ld a,Cross
    ld [Feedback],a
    ret
.home:
    ld a,Parcel
    ld [Home],a
    ret

; Original 8×8 art. With high plane zero, low-plane bits draw shade 1.
tiles:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,$ff,0,$ff,0,0,0,0,0,0,0        ; horizontal track
    db 0,0,$10,0,$18,0,$fc,0,$fc,0,$18,0,$10,0,0,0 ; route arrow
    db 0,0,$7e,0,$42,0,$5a,0,$5a,0,$42,0,$7e,0,0,0 ; delivery target
    db 0,0,$18,0,$3c,0,$7e,0,$7e,0,$3c,0,$18,0,0,0 ; parcel
    db 0,0,$02,0,$06,0,$4c,0,$78,0,$30,0,0,0,0,0   ; delivered
    db 0,0,$42,0,$66,0,$3c,0,$3c,0,$66,0,$42,0,0,0 ; missed
    db 0,0,0,0,0,0,$1f,0,$1f,0,$18,0,$18,0,$18,0  ; upper bend
    db $18,0,$18,0,$18,0,$f8,0,$f8,0,$18,0,$18,0,$18,0 ; fork
    db $18,0,$18,0,$18,0,$1f,0,$1f,0,0,0,0,0,0,0  ; lower bend
tiles_end:
    ds $8000-@,0
