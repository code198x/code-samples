; Shared DMG cartridge header, background setup, and original tile art.
rLCDC EQU $FF40
rSCY  EQU $FF42
rSCX  EQU $FF43
rLY   EQU $FF44
rBGP  EQU $FF47
TileMap EQU $9800

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
; Set up VRAM with the LCD off. Leaves it off so the checkpoint can
; draw its initial state before calling show_yard.
setup_yard:
.wait_to_disable:
    ld a,[rLY]
    cp 144                  ; First scanline of VBlank.
    jr c,.wait_to_disable
    xor a
    ld [rLCDC],a
    ld [rSCY],a
    ld [rSCX],a

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

    ; Idle scene: the marked destination and a parcel waiting at home.
    ld a,Target
    ld [UpperDepot],a
    ld a,Parcel
    ld [Home],a
    ret

show_yard:
    ld a,$ec                ; map our ink (colour index 1) to black
    ld [rBGP],a
    ld a,$91                ; LCD and BG on; unsigned tile IDs at $8000.
    ld [rLCDC],a
    ret

; Wait for the next VBlank, not the remainder of the current one.
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
