;──────────────────────────────────────────────────────────────
; FLOCK - A sheep-crossing arcade game for the Commodore Amiga
; Unit 12: The Stream
;
; The rule flips. The water is deadly now — step in and she
; drowns — UNLESS she lands on the drifting hay bale, which
; carries her, or keeps to the footbridge. Same collision
; hardware as the road, opposite law: on the lane, touching
; the sprite kills; on the stream, NOT touching one does.
; One CLXDAT read now serves two judges, so the read becomes
; a shared copy — and the bale shares the cart's collision
; bit, so position decides which one the contact means.
;──────────────────────────────────────────────────────────────

;══════════════════════════════════════════════════════════════
; TWEAKABLE VALUES — Change these and see what happens!
;══════════════════════════════════════════════════════════════

; Colours are $0RGB (4 bits per component, values 0-F)
COLOUR_FOLD_GRASS   equ $0480       ; The fold's pasture
COLOUR_HEDGE        equ $0350       ; Hedgerow between fold and stream
COLOUR_WATER        equ $036A       ; The stream
COLOUR_BANK         equ $0350       ; Grassy bank below the stream
COLOUR_LANE         equ $0666       ; The lane's tarmac
COLOUR_VERGE        equ $0350       ; Verge below the lane
COLOUR_FIELD        equ $0470       ; The field where the flock waits

COLOUR_FENCE        equ $0531       ; Pen walls (bitplane, fold band)
COLOUR_WOOD         equ $0852       ; The footbridge (bitplane, stream band)
COLOUR_DASH         equ $0EEE       ; Lane markings (bitplane, lane band)
COLOUR_TUFT         equ $0360       ; Spare (bitplane, grass bands)

COLOUR_WOOL         equ $0EEE       ; The sheep's fleece (sprite colour 1)
COLOUR_FACE         equ $0210       ; Her face, ears and tail (sprite colour 2)
COLOUR_SHADE        equ $0BBB       ; Fleece shading (sprite colour 3)
COLOUR_SOOT         equ $0333       ; A black sheep's fleece
COLOUR_SOOTFACE     equ $0CCC       ; ...and her pale face
COLOUR_SOOTSHADE    equ $0222       ; ...and her shading

COLOUR_TRACTOR      equ $0B20       ; The tractor's bodywork (sprite colour 1)
COLOUR_TYRE         equ $0210       ; Wheels and trim (sprite colour 2)
COLOUR_CAB          equ $0999       ; The cab roof (sprite colour 3)

COLOUR_WOODWORK     equ $0742       ; The hay cart's bed (sprites 4-5)
COLOUR_HAY          equ $0C92       ; Its heaped load

COLOUR_ROVER        equ $0364       ; The Land Rover's paint (sprites 6-7)
COLOUR_ROOF         equ $0AAA       ; Its roof panel

; Where each band begins (screen row 0-255, top to bottom)
ROW_HEDGE           equ 40
ROW_STREAM          equ 48
ROW_BANK            equ 80
ROW_LANE            equ 96
ROW_VERGE           equ 160
ROW_FIELD           equ 176

; Where the sheep starts, and how she moves
SHEEP_X             equ 152
SHEEP_Y             equ 200
STEP                equ 8           ; Pixels per hop
COOLDOWN            equ 6           ; Frames between hops
SKITTISH            equ 4           ; A black sheep's quicker rhythm
NERVE_EDGE          equ 150         ; Three seconds' dithering: trembling
NERVE_BOLT          equ 250         ; Five: the wind's up, she bolts
PANIC_HOPS          equ 3           ; How far a bolting sheep bolts

; The traffic: three lanes, three rhythms
TRACTOR_Y           equ 98          ; Top lane
TRACTOR_SPEED       equ 2           ; Steady, rightward
ROVER_Y             equ 120         ; Middle lane
ROVER_SPEED         equ -3          ; Fast, leftward
CART_Y              equ 142         ; Bottom lane — crossed first
CART_SPEED          equ -1          ; Plodding, leftward

; How long the world stops when a sheep is lost
SQUASH_BEAT         equ 25          ; Frames of stillness

; The flock
FLOCK_SIZE          equ 5           ; Sheep in hand at the start
ENDWAIT             equ 300         ; Frames to sit with the ending
WINWAIT             equ 180         ; ...and to savour a full fold
SHEPHERD_BONUS      equ 250         ; A clean flock: nobody lost
MAXLEVEL            equ 4           ; The table's last row repeats
JINGLE_VOL          equ 48          ; The title tune's voice
; The jingle's notes (PAL: period = 3546895 / (freq * 8))
NOTE_C              equ 1694
NOTE_D              equ 1510
NOTE_E               equ 1345
NOTE_F              equ 1270
NOTE_G              equ 1131
NOTE_A              equ 1008

; The fold's pens
PEN_ROW             equ 16          ; Where a resident sheep settles
FENCE_Y             equ 24          ; She stops here unless a pen is open
PEN_BEAT            equ 15          ; Frames of calm after a penning

; What things are worth
ROAD_POINTS         equ 5           ; Surviving the road (per sheep)
PEN_POINTS          equ 25          ; A sheep safely home
BLACK_BONUS         equ 100         ; ...and a black one besides
ROW_BANK_TOP        equ 88          ; Past here, the road is behind her

; The farmyard's voice: each sound is two periods (pitch
; slides from the first to the second halfway through), a
; volume, and a length in frames. Bigger period = lower note.
BAA_PER1            equ 1800        ; The hop: a soft baa,
BAA_PER2            equ 2100        ;   dropping as it ends
BAA_FRAMES          equ 5 
BAA_VOL             equ 40
SPLAT_PER1          equ 2800        ; The loss: low and flat,
SPLAT_PER2          equ 3600        ;   sagging lower
SPLAT_FRAMES        equ 16
SPLAT_VOL           equ 60
BLEAT_PER1          equ 1700        ; The pen: contented,
BLEAT_PER2          equ 1250        ;   rising
BLEAT_FRAMES        equ 18
BLEAT_VOL           equ 50
CHIME_PER1          equ 850         ; The black sheep's chime:
CHIME_PER2          equ 560         ;   high, bright, rising
CHIME_FRAMES        equ 22
CHIME_VOL           equ 58
FRET_PER1           equ 1150        ; The nervous baa: thin,
FRET_PER2           equ 1400        ;   falling, worried
FRET_FRAMES         equ 8
FRET_VOL            equ 42
DROWN_PER1          equ 2200        ; The stream: a swallowed
DROWN_PER2          equ 3400        ;   glub, sinking
DROWN_FRAMES        equ 14
DROWN_VOL           equ 55

; The stream and its crossings
STREAM_TOP          equ 44          ; She's in the water between
STREAM_BOT          equ 76          ;   these rows...
BRIDGE_MINX         equ 144         ; ...unless on the footbridge
BRIDGE_MAXX         equ 176         ;   (sheep-centre span)...
BALE_Y              equ 60          ; ...or aboard the hay bale
DUCK_Y              equ 46          ; The duck paddles the north water
DUCK_SPEED          equ -1          ; ...heading the other way
DUCK_PADDLE         equ 220         ; Frames afloat between feeds
DUCK_WARN           equ 50          ; Tail-up: the warning she gives
DUCK_UNDER          equ 120         ; Frames spent feeding below
COW_Y               equ 160         ; The verge is HER lane
COW_SPEED           equ 1<<15       ; Half a pixel a frame, in 16.16
BALE_SPEED          equ 1           ; It drifts gently rightward

; The HUD strip at the foot of the screen
ROW_HUD             equ 240
COLOUR_HUD          equ $0231       ; The strip itself
COLOUR_ICON         equ $0EEE       ; Sheep icons (bitplane, HUD band)

;══════════════════════════════════════════════════════════════
; HARDWARE REGISTERS
;══════════════════════════════════════════════════════════════

CUSTOM      equ $dff000

DMACON      equ $096        ; DMA control (write)
INTENA      equ $09a        ; Interrupt enable (write)
INTREQ      equ $09c        ; Interrupt request (write)
COP1LC      equ $080        ; Copper list pointer
COPJMP1     equ $088        ; Copper restart strobe
VPOSR       equ $004        ; Beam position
JOY1DAT     equ $00c        ; Joystick, control port 2
CLXDAT      equ $00e        ; Collision data (read clears it!)
CLXCON      equ $098        ; Collision control
AUD0LC      equ $0a0        ; Audio channel 0: sample address
AUD0LEN     equ $0a4        ;   sample length (words)
AUD0PER     equ $0a6        ;   period (pitch)
AUD0VOL     equ $0a8        ;   volume (0-64)

BPLCON0     equ $100        ; Bitplane control
BPLCON1     equ $102        ; Scroll
BPLCON2     equ $104        ; Priority
BPL1MOD     equ $108        ; Odd plane modulo
DDFSTRT     equ $092        ; Display data fetch start
DDFSTOP     equ $094        ; Display data fetch stop
DIWSTRT     equ $08e        ; Display window start
DIWSTOP     equ $090        ; Display window stop
BPL1PTH     equ $0e0        ; Bitplane 1 pointer (high)
BPL1PTL     equ $0e2        ; Bitplane 1 pointer (low)
BPL2PTH     equ $0e4        ; Bitplane 2 pointer (high)
BPL2PTL     equ $0e6        ; Bitplane 2 pointer (low)
BPL2MOD     equ $10a        ; Even plane modulo
SPR0PTH     equ $120        ; Sprite 0 pointer (high)
COLOR00     equ $180        ; Background colour
COLOR01     equ $182        ; Bitplane colour 1
COLOR02     equ $184        ; Bitplane colour 2 (plane 2)
COLOR03     equ $186        ; Bitplane colour 3 (both planes)
COLOR17     equ $1a2        ; Sprite 0/1 colour 1
COLOR18     equ $1a4        ; Sprite 0/1 colour 2
COLOR19     equ $1a6        ; Sprite 0/1 colour 3
COLOR21     equ $1aa        ; Sprite 2/3 colour 1
COLOR22     equ $1ac        ; Sprite 2/3 colour 2
COLOR23     equ $1ae        ; Sprite 2/3 colour 3
COLOR25     equ $1b2        ; Sprite 4/5 colour 1
COLOR26     equ $1b4        ; Sprite 4/5 colour 2
COLOR27     equ $1b6        ; Sprite 4/5 colour 3
COLOR29     equ $1ba        ; Sprite 6/7 colour 1
COLOR30     equ $1bc        ; Sprite 6/7 colour 2
COLOR31     equ $1be        ; Sprite 6/7 colour 3

ROW_BYTES   equ 40          ; 320 pixels / 8

;══════════════════════════════════════════════════════════════
; CODE (Chip RAM — the Copper, planes and sprites live here)
;══════════════════════════════════════════════════════════════

            section code,code_c

start:
            lea     CUSTOM,a5           ; A5 = custom chip base ($DFF000)

            ; --- Take over the machine ---
            move.w  #$7fff,INTENA(a5)   ; Disable all interrupts
            move.w  #$7fff,INTREQ(a5)   ; Clear pending interrupts
            move.w  #$7fff,DMACON(a5)   ; Disable all DMA

            ; --- Point the Copper's bitplane MOVEs at our planes ---
            lea     copbpl,a1
            lea     plane,a0
            move.l  a0,d0
            move.w  d0,6(a1)            ; Low word into the BPL1PTL move
            swap    d0
            move.w  d0,2(a1)            ; High word into the BPL1PTH move
            lea     plane2,a0
            move.l  a0,d0
            move.w  d0,14(a1)           ; And the same for plane 2
            swap    d0
            move.w  d0,10(a1)

            ; --- Point sprite 0 at the sheep, the rest at nothing ---
            lea     copsprites,a1       ; Eight pointer pairs in the list
            lea     sheep0,a0
            move.l  a0,d0
            move.w  d0,6(a1)            ; Sprite 0 low word
            swap    d0
            move.w  d0,2(a1)            ; Sprite 0 high word

            lea     nullspr,a0          ; Sprites 1-7: an empty sprite
            move.l  a0,d0
            moveq   #7-1,d6
.nulls:
            lea     8(a1),a1            ; Next pointer pair in the list
            move.w  d0,6(a1)
            swap    d0
            move.w  d0,2(a1)
            swap    d0
            dbf     d6,.nulls

            ; --- ...except the traffic: sprites 2, 4 and 6.
            ; Each vehicle gets the EVEN sprite of its own pair, so
            ; each lives in its own collision group: tractor in 2/3
            ; (bit 9 against the sheep), cart in 4/5 (bit 10),
            ; Land Rover in 6/7 (bit 11) — and its own palette.
            lea     copsprites+16,a1    ; Sprite 2: the tractor
            lea     tractor,a0
            move.l  a0,d0
            move.w  d0,6(a1)
            swap    d0
            move.w  d0,2(a1)
            lea     copsprites+32,a1    ; Sprite 4: the hay cart
            lea     cart,a0
            move.l  a0,d0
            move.w  d0,6(a1)
            swap    d0
            move.w  d0,2(a1)
            lea     copsprites+48,a1    ; Sprite 6: the Land Rover
            lea     rover,a0
            move.l  a0,d0
            move.w  d0,6(a1)
            swap    d0
            move.w  d0,2(a1)
            lea     copsprites+40,a1    ; Sprite 5: the hay bale —
            lea     bale,a0             ;   the cart's pair, so it
            move.l  a0,d0               ;   borrows the hay palette
            move.w  d0,6(a1)            ;   AND the cart's collision
            swap    d0                  ;   bit. Position will tell
            move.w  d0,2(a1)            ;   them apart.


            lea     copsprites+24,a1    ; Sprite 3: the cow — the
            lea     cow,a0              ;   tractor's pair, so she
            move.l  a0,d0               ;   shares its colours AND its
            move.w  d0,6(a1)            ;   bit 9 — the bit that kills
            swap    d0                  ;   without asking where you
            move.w  d0,2(a1)            ;   were standing.

            lea     copsprites+56,a1    ; Sprite 7: the duck — the
            lea     duck,a0             ;   Rover's pair, so she borrows
            move.l  a0,d0               ;   the Rover's palette AND its
            move.w  d0,6(a1)            ;   collision bit. Position will
            swap    d0                  ;   tell them apart, as it does
            move.w  d0,2(a1)            ;   for the cart and the bale.

            ; --- Arm collision detection ---
            move.w  #$e000,CLXCON(a5)   ; ENSP3+5+7: odd sprites sit OUT
                                        ;   of collision unless invited —
                                        ;   the cow, the bale and the
                                        ;   duck all need their bits set
            move.w  CLXDAT(a5),d0       ; Prime: reading clears the latches

            ; --- Draw the farmyard's detail into the bitplane ---
            bsr     drawfarmyard
            bsr     drawflock           ; The flock in hand, bottom-left
            bsr     drawscore           ; And the score, bottom-right

            ; --- Place the sheep at her starting spot ---
            bsr     newsheep            ; Even the first one rolls
            bsr     updsprite
            bsr     drawtitle           ; ...but the game opens on the
                                        ;   title, sheep in the wings

            ; --- Install Copper list ---
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)      ; Strobe: restart Copper from COP1LC

            ; --- Enable DMA ---
            move.w  #$83a0,DMACON(a5)   ; SET + DMAEN + BPLEN + COPEN + SPREN

            ; === Main Loop ===
mainloop:
            ; Wait for vertical blank — in two phases. If we only
            ; waited FOR line 0, a fast loop body could finish while
            ; the beam is still ON line 0 and run again in the same
            ; frame. Wait to leave line 0 first, then to reach it.
            move.l  #$1ff00,d1          ; Mask: bits 8-16 of beam position
.vbleave:
            move.l  VPOSR(a5),d0        ; Read beam position
            and.l   d1,d0               ; Isolate line number
            beq.s   .vbleave            ; Loop while still on line 0
.vbwait:
            move.l  VPOSR(a5),d0        ; Read beam position
            and.l   d1,d0               ; Isolate line number
            bne.s   .vbwait             ; Loop until line 0 again
            ; The line number spans TWO registers, and the 68000
            ; reads them one after the other. Catch the beam mid-
            ; crossing (255 to 256) and the halves disagree: V8
            ; from the old line, V0-V7 from the new one — a line
            ; that reads as 0 but isn't. Read again: a real line 0
            ; stays 0, a phantom is gone by the second look.
            move.l  VPOSR(a5),d0        ; Confirm against a second read
            and.l   d1,d0
            bne.s   .vbwait             ; Phantom — keep waiting

            addq.w  #1,framecnt         ; The entropy clock ticks
            ; --- Two games share one loop: the title is a game ---
            ; whose only verb is "press fire". The world drives on
            ; in both states; only the sheep-facing systems switch.
            tst.w   gamestate
            bne.s   .playing

            ; — TITLE: attract mode —
            bsr     drivelanes          ; The farm doesn't stop for
            bsr     tendduck            ;   a title — that's the charm
            bsr     tunetick            ; The jingle walks its table
            bsr     soundtick
            bsr     updsprite
            bsr     showframe           ; (Hides the sheep: see below)
            bsr     checkfire           ; Fire starts the game
            bra.s   .endloop

.playing:
            bsr     steer               ; Read the stick, maybe hop
            bsr     fret                ; Standing still has a price
            bsr     drivelanes          ; All the traffic, one mover
            bsr     tendduck            ; Paddle, warn, vanish, return
            move.w  CLXDAT(a5),contacts ; ONE read; every judge shares it
            bsr     checksquash         ; Did the lane win?
            bsr     checkstream         ; Did the water?
            bsr     soundtick           ; Wobble, and fall silent on time
            bsr     updsprite           ; Position is data: rewrite POS/CTL
            bsr     showframe           ; Point sprite 0 at this step's image
            bsr     endtick             ; Won or lost: sit, then title

.endloop:
            ; Check left mouse button (active low at CIAA)
            btst    #6,$bfe001          ; CIAA Port A, bit 6
            bne     mainloop            ; Not pressed — keep going

            ; Button pressed — halt
.halt:
            bra.s   .halt

;══════════════════════════════════════════════════════════════
; STEER — read the joystick, hop the sheep
;
; JOY1DAT is control port 2. The decode is famously sideways:
;   right = bit 1            left = bit 9
;   down  = bit 0 XOR bit 1  up   = bit 8 XOR bit 9
; One XOR of the register with itself-shifted turns the two
; awkward pairs into plain testable bits.
;
; A hop is STEP pixels; COOLDOWN frames must pass between hops
; — that's what makes her *step* like a sheep rather than glide
; like a cursor.
;══════════════════════════════════════════════════════════════

steer:
            tst.w   won                 ; Fold full — nothing to steer
            bne.s   .frozen
            tst.w   gameover            ; No flock, no shepherd
            bne.s   .frozen
            tst.w   squashtimer         ; Mid squash-beat? She can't move
            beq.s   .alive
.frozen:    rts
.alive:
            tst.w   cooldown
            beq.s   .ready
            subq.w  #1,cooldown         ; Mid-rhythm — but LISTEN: a
            move.w  JOY1DAT(a5),d0      ;   tap during the cooldown
            move.w  d0,d1               ;   used to vanish. Bank it
            lsr.w   #1,d1               ;   and serve it when ready —
            eor.w   d0,d1               ;   that's input buffering,
            and.w   #$0303,d1           ;   and it's most of "feel".
            bne.s   .moving
            move.w  #1,sawneutral       ; The stick came home
            rts
.moving:
            tst.w   sawneutral          ; Only a FRESH press banks —
            beq.s   .nobuf              ;   the press that caused this
            move.w  d0,hopbuf           ;   hop must not echo itself
.nobuf:     rts
.ready:
            tst.w   panic               ; Bolting? She's not asking
            beq.s   .listening
            subq.w  #1,panic
            cmp.w   #FENCE_Y,sheepy     ; A bolt is an UP that ignores
            bgt.s   .bolthop            ;   the stick entirely
            bsr     trypen              ; Bolting at the fence: she
            bra     .done               ;   slams into it (or a pen)
.bolthop:
            sub.w   #STEP,sheepy
            bra     .stepped
.listening:
            move.w  JOY1DAT(a5),d0      ; Read the stick
            tst.w   hopbuf              ; A banked tap outranks the
            beq.s   .live               ;   stick's present mood —
            move.w  hopbuf,d0           ;   replayed RAW, so left and
            clr.w   hopbuf              ;   right replay too (steer
.live:                                  ;   tests those bits in D0)
            move.w  d0,d1
            lsr.w   #1,d1
            eor.w   d0,d1               ; Now: bit 0 = down, bit 8 = up

            btst    #8,d1               ; Up?
            beq.s   .notup
            cmp.w   #FENCE_Y,sheepy     ; At the fence line?
            bgt.s   .climb
            bsr     trypen              ; Only a pen lets her past
            bra     .done
.climb:
            sub.w   #STEP,sheepy
            bra.s   .stepped
.notup:
            btst    #0,d1               ; Down?
            beq.s   .notdown
            add.w   #STEP,sheepy
            bra.s   .stepped
.notdown:
            btst    #9,d0               ; Left?
            beq.s   .notleft
            sub.w   #STEP,sheepx
            bra.s   .stepped
.notleft:
            btst    #1,d0               ; Right?
            beq     .done               ; Stick centred — no hop
            add.w   #STEP,sheepx
.stepped:
            move.w  hopgap,cooldown     ; Set THIS sheep's hop rhythm
            eori.w  #1,curframe         ; The other feet, next picture
            clr.w   nerve               ; Moving keeps the fear down
            clr.w   fretted
            clr.w   sawneutral          ; New rhythm, new window

            ; --- The hop has a voice ---
            move.w  #BAA_PER1,d0
            move.w  #BAA_PER2,d1
            move.w  #BAA_FRAMES,d2
            move.w  #BAA_VOL,d3
            bsr     playsound

            ; --- First time past the road? That's worth something.
            tst.w   roadflag
            bne.s   .scored
            cmp.w   #ROW_BANK_TOP,sheepy
            bgt.s   .scored
            move.w  #1,roadflag
            add.w   #ROAD_POINTS,score
            bsr     drawscore
.scored:

            ; --- Hold her inside the farm ---
            tst.w   sheepx
            bge.s   .xlow
            clr.w   sheepx
.xlow:      cmp.w   #320-16,sheepx
            ble.s   .xhigh
            move.w  #320-16,sheepx
.xhigh:     cmp.w   #FENCE_Y,sheepy     ; The fence is the ceiling;
            bge.s   .ylow               ;   pens are the only way past
            move.w  #FENCE_Y,sheepy
.ylow:      cmp.w   #ROW_HUD-16,sheepy  ; The HUD strip is not a pasture
            ble.s   .done
            move.w  #ROW_HUD-16,sheepy
.done:
            rts

;══════════════════════════════════════════════════════════════
; DRIVELANES — advance all the traffic
;
; FRET — the clock on her courage
;
; Mid-crossing, NERVE counts the frames since her last hop.
; Stand still too long and she trembles (showframe alternates
; her step images — the art was always two pictures, and fear
; is just walking on the spot); a worried baa marks the edge.
; Stand longer and the wind gets up: PANIC_HOPS involuntary
; hops, forward, stick ignored. Hopping anywhere resets the
; count — pressure only ever lands on the shepherd who stops.
;══════════════════════════════════════════════════════════════

fret:
            tst.w   gameover
            bne.s   .calm
            tst.w   won
            bne.s   .calm
            tst.w   squashtimer         ; Beats don't count as dithering
            bne.s   .calm
            tst.w   panic               ; Already bolting — fear's spent
            bne.s   .out
            cmp.w   #ROW_FIELD,sheepy   ; Home field: she grazes, easy
            bge.s   .calm
            addq.w  #1,nerve
            cmp.w   #NERVE_EDGE,nerve   ; Trembling point?
            blt.s   .out
            tst.w   fretted             ; One worried baa, not fifty
            bne.s   .past
            move.w  #1,fretted
            move.w  #FRET_PER1,d0
            move.w  #FRET_PER2,d1
            move.w  #FRET_FRAMES,d2
            move.w  #FRET_VOL,d3
            bsr     playsound
.past:
            move.w  nerve,d0            ; The wind's up (sooner, later
            cmp.w   nervebolt,d0        ;   levels — see applylevel)
            blt.s   .out
            move.w  #PANIC_HOPS,panic   ; She bolts — see steer
            clr.w   nerve
            clr.w   fretted
.out:       rts
.calm:
            clr.w   nerve
            clr.w   fretted
            rts

;══════════════════════════════════════════════════════════════
; Unit 5's mover, made data — and now made FRACTIONAL. Every
; position is a longword in 16.16 fixed point: the top word is
; the pixel, the bottom word is the fraction of a pixel the
; vehicle has earned but not yet shown. Adding a 16.16 speed
; each frame accumulates the fraction; when it overflows, the
; pixel above it ticks. The cow ambles at half a pixel a frame
; and the mover never knows she's special. And because the
; 68000 stores the high word FIRST, a plain move.w at the
; label still reads the pixel — every old word-read works.
;══════════════════════════════════════════════════════════════

drivelanes:
            lea     vehtab,a2
            moveq   #6-1,d6             ; Three vehicles, two ferries,
.veh:                                   ;   one cow
            move.l  (a2)+,a0            ; A0 = where this one's x lives
            move.l  (a2)+,d1            ; D1 = its speed (16.16, signed)
            move.l  (a0),d0
            add.l   d1,d0
            tst.l   d1
            bmi.s   .leftward
            cmp.l   #320<<16,d0         ; Rightward: clear of the right edge?
            blt.s   .store
            move.l  #-16<<16,d0         ; Re-enter from the left
            bra.s   .store
.leftward:
            cmp.l   #-16<<16,d0         ; Leftward: clear of the left edge?
            bgt.s   .store
            move.l  #320<<16,d0         ; Re-enter from the right
.store:
            move.l  d0,(a0)
            dbf     d6,.veh
            rts

vehtab:     dc.l    tractx
            dc.l    TRACTOR_SPEED<<16
            dc.l    cartx
            dc.l    CART_SPEED<<16
            dc.l    roverx
            dc.l    ROVER_SPEED<<16
            dc.l    balex
            dc.l    BALE_SPEED<<16
            dc.l    duckx
            dc.l    DUCK_SPEED<<16
            dc.l    cowx
            dc.l    COW_SPEED

;══════════════════════════════════════════════════════════════
; CHECKSQUASH — read the collision latches, judge the lane
;
; CLXDAT accumulates collisions as Denise draws, and READING
; IT CLEARS IT — so read it exactly once per frame and keep
; the copy. Bit 9 means "sprite 0 or 1 touched sprite 2 or 3":
; our sheep met our tractor, pixel against pixel. The hardware
; compared every overlapping pixel pair for us, for free.
;══════════════════════════════════════════════════════════════

checksquash:
            tst.w   squashtimer         ; Already mid-beat?
            beq.s   .watch
            subq.w  #1,squashtimer      ; Count the stillness down
            rts                         ; (No flush needed any more — the
                                        ;  shared read drains the latch
                                        ;  every frame, beat or no beat)
.watch:
            tst.w   gameover            ; Nothing left to lose?
            bne.s   .safe
            move.w  contacts,d0         ; The shared copy — no second read
            and.w   #$0200,d0           ; Bit 9 — tractor or cow: it
            bne.s   .squashed           ;   kills wherever she stands
            move.w  contacts,d0
            and.w   #$0c00,d0           ; Bits 10+11: cart or bale, Rover
            beq.s   .safe               ;   or duck — the shared bits...
            cmp.w   #ROW_BANK,sheepy    ; ...and they only mean the road
            blt.s   .safe               ;   pair when she's road-side
.squashed:
            ; --- Squashed. One fewer in hand. ---
            move.w  #SPLAT_PER1,d0
            move.w  #SPLAT_PER2,d1
            move.w  #SPLAT_FRAMES,d2
            move.w  #SPLAT_VOL,d3
            bsr     playsound
            bsr     losesheep
.safe:
            rts

;══════════════════════════════════════════════════════════════
; CHECKSTREAM — the water's law: ride or drown
;
; Only judges while she's in the stream rows. The footbridge
; column is dry land. Aboard a ferry — the bale (bit 10) or
; the duck (bit 11), up here where the road pair can't be —
; she's safe and CARRIED: the deck's drift becomes her
; movement, each at its own speed. Anything else is water.
;══════════════════════════════════════════════════════════════

checkstream:
            tst.w   squashtimer         ; The world can wait out a beat
            bne     .dry
            tst.w   gameover
            bne     .dry
            tst.w   won
            bne     .dry
            cmp.w   #STREAM_TOP,sheepy  ; In the water rows at all?
            blt     .dry
            cmp.w   #STREAM_BOT,sheepy
            bgt.s   .dry
            move.w  sheepx,d0
            addq.w  #8,d0               ; Her centre...
            cmp.w   #BRIDGE_MINX,d0     ; ...on the footbridge?
            blt.s   .wet
            cmp.w   #BRIDGE_MAXX,d0
            ble.s   .dry                ; Dry planks. Carry on.
.wet:
            move.w  contacts,d0
            and.w   #$0c00,d0           ; Either ferry under her feet?
            beq.s   .adrift
            clr.w   drownarm            ; Feet on something that floats
            btst    #10,d0              ; Which deck is she on?
            beq.s   .duckdeck
            add.w   #BALE_SPEED,sheepx  ; Carried with the bale's drift
            bra.s   .edges
.duckdeck:
            add.w   #DUCK_SPEED,sheepx  ; The duck paddles the other way
.edges:
            tst.w   sheepx              ; Carried off either end of the
            bmi.s   .drowned            ;   world is still a loss
            cmp.w   #320-16,sheepx
            blt     .dry
            bra.s   .drowned
.adrift:
            ; CLXDAT reports the PREVIOUS frame's drawing — the
            ; instant she lands on the bale, the evidence hasn't
            ; been drawn yet. The water forgives a moment of
            ; scrambling before it takes her.
            addq.w  #1,drownarm
            cmp.w   #3,drownarm         ; Three contactless frames
            blt.s   .dry
.drowned:
            clr.w   drownarm
            move.w  #DROWN_PER1,d0
            move.w  #DROWN_PER2,d1
            move.w  #DROWN_FRAMES,d2
            move.w  #DROWN_VOL,d3
            bsr     playsound
            bsr     losesheep
.dry:
            rts

;──────────────────────────────────────────────────────────────
; losesheep — one fewer in hand, however it happened
;──────────────────────────────────────────────────────────────
losesheep:
            subq.w  #1,lives
            bsr     drawflock           ; Redraw the strip
            tst.w   lives
            bgt.s   .next               ; Sheep remain — send the next one
            move.w  #1,gameover         ; The field is empty
            rts
.next:
            bsr     newsheep            ; The next sheep steps up
            move.w  #SQUASH_BEAT,squashtimer
            rts

;══════════════════════════════════════════════════════════════
; NEWSHEEP — the next one steps up, and the dice decide her coat
;
; One sheep in eight is black: worth BLACK_BONUS at the fold,
; and a touch quicker on her feet. The roll mixes the xorshift
; generator with FRAMECNT — a clock that's been ticking since
; power-on — so the dice land where the PLAYER's timing put
; them. A machine with no randomness borrows some from you.
;
; Her colours live in the Copper list, which is only data: the
; same trick that repoints sprites repaints a sheep — three
; words poked into the palette entries before she steps out.
;══════════════════════════════════════════════════════════════

newsheep:
            move.w  #SHEEP_X,sheepx
            move.w  #SHEEP_Y,sheepy
            clr.w   roadflag            ; A fresh road ahead of her
            clr.w   nerve               ; Fresh courage, too
            clr.w   fretted
            clr.w   panic
            clr.w   hopbuf              ; No inherited intentions
            clr.w   sawneutral
            bsr     rnd
            and.w   #7,d0               ; One face of an eight-sided die
            beq.s   .black
            clr.w   isblack
            move.w  #COOLDOWN,hopgap
            move.w  #COLOUR_WOOL,woolentry+2
            move.w  #COLOUR_FACE,faceentry+2
            move.w  #COLOUR_SHADE,shadeentry+2
            rts
.black:
            move.w  #1,isblack
            move.w  #SKITTISH,hopgap    ; Quicker on her feet
            move.w  #COLOUR_SOOT,woolentry+2
            move.w  #COLOUR_SOOTFACE,faceentry+2
            move.w  #COLOUR_SOOTSHADE,shadeentry+2
            rts

;──────────────────────────────────────────────────────────────
; rnd — 16-bit xorshift (7,9,8), stirred with the frame clock
;   returns D0 = next pseudo-random word
;──────────────────────────────────────────────────────────────
rnd:
            move.w  seed,d0
            move.w  framecnt,d1         ; EOR only takes a register
            eor.w   d1,d0               ; Stir in the player's timing
            move.w  d0,d1
            lsl.w   #7,d1               ; x ^= x << 7
            eor.w   d1,d0
            move.w  d0,d1
            lsr.w   #8,d1
            lsr.w   #1,d1               ; x ^= x >> 9
            eor.w   d1,d0
            move.w  d0,d1
            lsl.w   #8,d1               ; x ^= x << 8
            eor.w   d1,d0
            bne.s   .live
            move.w  #$ACE1,d0           ; Zero is the one dead state
.live:
            move.w  d0,seed
            rts

;══════════════════════════════════════════════════════════════
; CHECKFIRE / STARTGAME / ENDTICK / GOTOTITLE — the game's spine
;
; Title, play, won, lost — every finished game is a loop of
; states, and the transitions are where resets live. STARTGAME
; is the only place the game becomes new: lives, score, pens,
; nerves, the playfield itself. Miss one reset here and the
; second game inherits the first one's ghosts.
;══════════════════════════════════════════════════════════════

checkfire:
            btst    #7,$bfe001          ; Port 2 fire (active low)
            bne.s   .up
            tst.w   firewas             ; Only the EDGE starts a game —
            bne.s   .held               ;   a held button is one press
            move.w  #1,firewas
            bra.s   startgame
.up:        clr.w   firewas
.held:      rts

startgame:
            move.w  #1,gamestate
            move.w  #1,level
            bsr     applylevel
            move.w  #FLOCK_SIZE,lives
            clr.w   score
            move.w  #5,unpenned
            clr.w   won
            clr.w   gameover
            clr.w   endtimer
            lea     pentab,a2           ; Every pen empties
            moveq   #5-1,d6
.pen:       clr.b   5(a2)
            addq.l  #6,a2
            dbf     d6,.pen
            move.w  #$0001,DMACON(a5)   ; The jingle stops mid-note
            clr.w   sndtimer
            moveq   #0,d0               ; Clear the whole playfield and
            moveq   #0,d1               ;   redraw it: the title text
            moveq   #ROW_BYTES,d2       ;   goes, the pen glyphs go,
            move.w  #240,d3             ;   the farm comes back clean
            bsr     rectclear
            bsr     clearfold
            bsr     drawfarmyard
            bsr     drawflock
            bsr     drawscore
            bsr     newsheep
            rts

endtick:
            tst.w   won                 ; A full fold: the next field
            bne     .winning
            tst.w   gameover            ; An empty one: the long walk
            bne     .losing             ;   back to the title
            rts
.winning:
            addq.w  #1,endtimer
            cmp.w   #WINWAIT,endtimer   ; Savour it...
            blt.s   .out
            bra.s   nextlevel           ; ...then a harder farm
.losing:
            addq.w  #1,endtimer
            cmp.w   #ENDWAIT,endtimer   ; Let the loss land...
            blt.s   .out
            clr.w   gamestate           ; ...then back to the title.
            clr.w   endtimer            ; Score and flock stay on the
            bsr     drawtitle           ;   HUD: the title wears your
            lea     jingle,a0           ;   last game like a rosette
            move.l  a0,jinglep
            clr.w   jingletimer
.out:       rts

;──────────────────────────────────────────────────────────────
; nextlevel / applylevel — the escalation is a table row
;
; Everything that gets harder was already DATA: the vehtab
; speeds (16.16, so half-pixel steps exist), the duck's
; stamina, the nerve threshold. A level is one row of new
; values poked over the old — the same move that made the
; black sheep's coat. Lives carry over: the flock is the run.
;──────────────────────────────────────────────────────────────
nextlevel:
            clr.w   won
            clr.w   endtimer
            cmp.w   #MAXLEVEL,level     ; The last row repeats forever
            bge.s   .capped
            addq.w  #1,level
.capped:
            bsr     applylevel
            move.w  #5,unpenned         ; Five empty pens again
            lea     pentab,a2
            moveq   #5-1,d6
.pen:       clr.b   5(a2)
            addq.l  #6,a2
            dbf     d6,.pen
            moveq   #0,d0               ; Clear the fold's glyphs and
            moveq   #0,d1               ;   redraw the farm fresh
            moveq   #ROW_BYTES,d2
            move.w  #240,d3
            bsr     rectclear
            bsr     clearfold
            bsr     drawfarmyard
            bsr     drawflock
            bsr     drawscore
            bsr     newsheep
            rts

applylevel:
            move.w  level,d0
            subq.w  #1,d0
            mulu    #16,d0              ; 16 bytes a row
            lea     leveltab,a0
            adda.w  d0,a0
            lea     vehtab,a1
            move.l  (a0)+,4(a1)         ; Tractor's new pace
            move.l  (a0)+,12(a1)        ; The cart's
            move.l  (a0)+,20(a1)        ; The Rover's
            move.w  (a0)+,duckpaddle    ; The duck feeds more keenly
            move.w  (a0)+,nervebolt     ; And nerves fray faster
            rts

;══════════════════════════════════════════════════════════════
; DRAWTITLE — FLOCK, eight pixels at a stroke
;
; Block capitals built from filled rectangles — the same
; rectfill that built the farm, walking a table. Chunky is
; period-honest: fonts are data, and a five-letter logo is
; twenty rows of it.
;══════════════════════════════════════════════════════════════

drawtitle:
            moveq   #0,d0               ; Bare the whole road band —
            move.w  #96,d1              ;   the dashes would thread
            moveq   #ROW_BYTES,d2       ;   through the lettering
            move.w  #63,d3
            bsr     rectclear
            lea     titletab,a2
.rect:
            move.w  (a2)+,d0            ; x byte (-1 ends the table)
            bmi.s   .done
            move.w  (a2)+,d1            ; row
            move.w  (a2)+,d2            ; width in bytes
            move.w  (a2)+,d3            ; height in rows
            bsr     rectfill
            bra.s   .rect
.done:      rts

;══════════════════════════════════════════════════════════════
; TUNETICK — the sequencer soundtick was always going to need
;
; A melody is a table: period, frames, period, frames... and a
; zero to loop. Each entry is one playsound call; the tick just
; watches the clock and serves the next note. Unit 11 played
; one sound at a time; this plays one sound at a time, forever,
; in order — that's all a jingle is. A zero period is a rest.
;══════════════════════════════════════════════════════════════

tunetick:
            tst.w   jingletimer
            beq.s   .next
            subq.w  #1,jingletimer
            rts
.next:
            move.l  jinglep,a0
            move.w  (a0)+,d0            ; Period (0 = rest, -1 = loop)
            bmi.s   .loop
            move.w  (a0)+,d2            ; Frames
            move.w  d2,jingletimer
            move.l  a0,jinglep
            tst.w   d0
            beq.s   .rest
            move.w  d0,d1               ; Steady pitch: both periods
            move.w  #JINGLE_VOL,d3      ;   the same, no slide
            bra     playsound
.rest:
            move.w  #$0001,DMACON(a5)   ; Silence is a note too
            rts
.loop:
            lea     jingle,a0
            move.l  a0,jinglep
            rts

;══════════════════════════════════════════════════════════════
; SETPOS — pack screen (x, y) into one sprite's POS/CTL
;   a0 = sprite structure   d0 = x   d1 = y
;
; Unit 3's packing, generalised: any sprite, any position. Beam
; coordinates: VSTART = y + $2C, HSTART = x + $80 — and the
; ninth bits ride in CTL's low flags.
;══════════════════════════════════════════════════════════════

setpos:
            add.w   #$2c,d1             ; D1 = VSTART (beam line)
            move.w  d1,d2
            add.w   #16,d2              ; D2 = VSTOP (16 rows tall)
            add.w   #$80,d0             ; D0 = HSTART (beam position)

            ; POS = VSTART[7:0] << 8 | HSTART[8:1]
            move.w  d1,d3
            lsl.w   #8,d3
            move.w  d0,d4
            lsr.w   #1,d4
            and.w   #$ff,d4
            or.w    d4,d3
            move.w  d3,(a0)             ; Write POS

            ; CTL = VSTOP[7:0] << 8 | V8START<<2 | V8STOP<<1 | H0START
            move.w  d2,d3
            and.w   #$ff,d3
            lsl.w   #8,d3
            btst    #8,d1               ; VSTART's ninth bit
            beq.s   .nv8s
            or.w    #%100,d3
.nv8s:      btst    #8,d2               ; VSTOP's ninth bit
            beq.s   .nv8e
            or.w    #%010,d3
.nv8e:      btst    #0,d0               ; HSTART's odd-pixel bit
            beq.s   .nh0
            or.w    #%001,d3
.nh0:       move.w  d3,2(a0)            ; Write CTL
            rts

;══════════════════════════════════════════════════════════════
; TENDDUCK — the paddle / tail-up / gone cycle
;
; A timer and three states, and the sprite POINTER is the
; state: paddling art, warning art, or the null sprite. While
; she feeds there are no pixels — and no pixels means no
; collision evidence, so the water's law needs no special
; case for a vanished ferry. Her rider is simply adrift.
;══════════════════════════════════════════════════════════════

tendduck:
            subq.w  #1,ducktimer
            bgt.s   .done               ; Still mid-state
            move.w  duckstate,d0
            addq.w  #1,d0
            cmp.w   #3,d0
            blt.s   .store
            moveq   #0,d0               ; ...and up she pops again
.store:
            move.w  d0,duckstate
            lea     duck,a0             ; 0: paddling, deck open
            move.w  duckpaddle,ducktimer ; (The level sets her stamina)
            tst.w   d0
            beq.s   .point
            lea     duckwarn,a0         ; 1: tail up — fair warning
            move.w  #DUCK_WARN,ducktimer
            cmp.w   #1,d0
            beq.s   .point
            lea     nullspr,a0          ; 2: under. No pixels, no deck.
            move.w  #DUCK_UNDER,ducktimer
.point:
            lea     copsprites+56,a1    ; Sprite 7's pointer words
            move.l  a0,d0
            move.w  d0,6(a1)
            swap    d0
            move.w  d0,2(a1)
.done:      rts

;══════════════════════════════════════════════════════════════
; UPDSPRITE — place every sprite for this frame
;
; One routine owns every position write: the sheep (both step
; images, so whichever showframe picks she stands in the same
; place) and the tractor.
;══════════════════════════════════════════════════════════════

updsprite:
            lea     sheep0,a0
            move.w  sheepx,d0
            move.w  sheepy,d1
            bsr     setpos
            lea     sheep1,a0
            move.w  sheepx,d0
            move.w  sheepy,d1
            bsr     setpos
            lea     tractor,a0
            move.w  tractx,d0
            move.w  #TRACTOR_Y,d1
            bsr     setpos
            lea     cart,a0
            move.w  cartx,d0
            move.w  #CART_Y,d1
            bsr     setpos
            lea     rover,a0
            move.w  roverx,d0
            move.w  #ROVER_Y,d1
            bsr     setpos
            lea     bale,a0
            move.w  balex,d0
            move.w  #BALE_Y,d1
            bsr     setpos
            lea     duck,a0
            move.w  duckx,d0
            move.w  #DUCK_Y,d1
            bsr     setpos
            lea     duckwarn,a0         ; Both poses, same spot — like
            move.w  duckx,d0            ;   the sheep's two step images
            move.w  #DUCK_Y,d1
            bsr     setpos
            lea     cow,a0
            move.w  cowx,d0             ; A word read of a 16.16 long
            move.w  #COW_Y,d1           ;   is the integer part — free
            bsr     setpos
            rts

;══════════════════════════════════════════════════════════════
; SHOWFRAME — point sprite 0 at this step's image
;
; Animation is nothing but choosing which data the channel
; fetches. The Copper list's sprite 0 pointer words are
; rewritten with whichever picture curframe names — the same
; poke the startup code did, now done every frame.
;══════════════════════════════════════════════════════════════

showframe:
            lea     nullspr,a0          ; Game over, the whole flock
            tst.w   gamestate           ;   home, or the title screen:
            beq.s   .picked             ;   no sheep on the move
            tst.w   gameover
            bne.s   .picked
            tst.w   won
            bne.s   .picked
            lea     sheep0,a0
            move.w  curframe,d0
            cmp.w   #NERVE_EDGE,nerve   ; Trembling: walk on the spot —
            blt.s   .steady             ;   the step images alternate
            move.w  framecnt,d0         ;   every few frames, going
            lsr.w   #2,d0               ;   nowhere
.steady:
            and.w   #1,d0
            beq.s   .picked
            lea     sheep1,a0
.picked:
            move.l  a0,d0
            lea     copsprites,a1
            move.w  d0,6(a1)            ; Sprite 0 low word
            swap    d0
            move.w  d0,2(a1)            ; Sprite 0 high word
            rts

;══════════════════════════════════════════════════════════════
; DRAW THE FARMYARD (unchanged from Unit 1)
;══════════════════════════════════════════════════════════════

drawfarmyard:
            ; --- The fold's pens (rows 4-35) ---
            moveq   #0,d0               ; x = byte 0
            moveq   #4,d1               ; row 4
            moveq   #ROW_BYTES,d2       ; full width
            moveq   #4,d3               ; 4 rows thick
            bsr     rectfill

            lea     penposts,a2         ; Post positions (byte columns)
            moveq   #6-1,d6             ; Six posts
.posts:
            moveq   #0,d0
            move.b  (a2)+,d0            ; x = next post column
            moveq   #8,d1               ; rows 8-35
            moveq   #1,d2               ; one byte wide
            moveq   #28,d3
            bsr     rectfill
            dbf     d6,.posts

            ; --- The footbridge (rows 48-79, mid-stream) ---
            moveq   #18,d0              ; byte 18 = pixel 144
            moveq   #ROW_STREAM,d1
            moveq   #4,d2               ; 32 pixels wide
            moveq   #32,d3              ; the stream's full height
            bsr     rectfill

            ; --- Lane markings: two dashed lines (rows 116, 136) ---
            moveq   #116,d1
            bsr     dashline
            move.w  #136,d1
            ; falls through

;──────────────────────────────────────────────────────────────
; dashline — a row of dashes across the lane
;   d1 = starting row. 2 bytes on, 2 bytes off, 4 rows thick.
;──────────────────────────────────────────────────────────────
dashline:
            moveq   #0,d0               ; x = byte 0
.dash:
            move.w  d1,-(sp)            ; rectfill trashes d1
            move.w  d0,-(sp)            ; ...and d0
            moveq   #2,d2               ; 2 bytes of dash
            moveq   #4,d3               ; 4 rows thick
            bsr     rectfill
            move.w  (sp)+,d0
            move.w  (sp)+,d1
            addq.w  #4,d0               ; next dash 4 bytes along
            cmp.w   #ROW_BYTES,d0
            blt.s   .dash
            rts

;──────────────────────────────────────────────────────────────
; rectfill — set a byte-aligned rectangle of pixels
;   d0 = x (bytes)   d1 = row   d2 = width (bytes)   d3 = height
;   Trashes d1, d4, d5, a0, a1.
;──────────────────────────────────────────────────────────────
rectfill:
            lea     plane,a0
            move.w  d1,d4
            mulu    #ROW_BYTES,d4       ; row * 40
            add.w   d0,d4               ; + x
            adda.w  d4,a0               ; A0 = first byte of the rectangle
            move.w  d3,d4               ; D4 = rows to go
.row:
            movea.l a0,a1
            move.w  d2,d5               ; D5 = bytes to go
.col:
            move.b  #$ff,(a1)+          ; 8 pixels on
            subq.w  #1,d5
            bne.s   .col
            lea     ROW_BYTES(a0),a0    ; down one row
            subq.w  #1,d4
            bne.s   .row
            rts

penposts:   dc.b    0,8,16,24,32,39     ; Byte columns of the six posts
            even

;══════════════════════════════════════════════════════════════
; TRYPEN — at the fence, try to enter the pen she's facing
;
; Each pentab row is a pen: the span of sheep-centre x values
; it accepts, the byte column its resident glyph is drawn at,
; and a flag byte that remembers it's taken. A hit pens her:
; the resident appears (plane 2 — white among the brown
; fences), the next sheep steps up, and a full fold wins.
;══════════════════════════════════════════════════════════════

trypen:
            move.w  sheepx,d0
            addq.w  #8,d0               ; D0 = her centre
            lea     pentab,a2
            moveq   #5-1,d6
.pen:
            cmp.w   (a2),d0             ; Left of this pen?
            blt     .nextpen
            cmp.w   2(a2),d0            ; Right of it?
            bgt     .nextpen
            tst.b   5(a2)               ; Already taken?
            bne     .nextpen
            ; --- She's in. A resident for the fold. ---
            move.b  #1,5(a2)
            move.w  4(a2),d0            ; Glyph byte column
            and.w   #$ff00,d0
            lsr.w   #8,d0
            bsr     penglyph
            move.w  #BLEAT_PER1,d0      ; A contented sound
            move.w  #BLEAT_PER2,d1
            move.w  #BLEAT_FRAMES,d2
            move.w  #BLEAT_VOL,d3
            tst.w   isblack             ; ...unless she's the gamble —
            beq.s   .sing
            move.w  #CHIME_PER1,d0      ;   then the game's best sound
            move.w  #CHIME_PER2,d1
            move.w  #CHIME_FRAMES,d2
            move.w  #CHIME_VOL,d3
.sing:
            bsr     playsound
            add.w   #PEN_POINTS,score   ; A sheep safely home
            tst.w   isblack
            beq.s   .paid
            add.w   #BLACK_BONUS,score  ; The gamble pays
.paid:
            bsr     drawscore
            bsr     newsheep            ; The next sheep steps up
            move.w  #PEN_BEAT,squashtimer
            subq.w  #1,unpenned         ; A full fold ends the level
            bne.s   .out
            move.w  #1,won
            cmp.w   #FLOCK_SIZE,lives   ; The whole flock, nobody lost?
            bne.s   .out
            add.w   #SHEPHERD_BONUS,score
            bsr     drawscore           ; The shepherd's bonus, banked
.out:
            rts
.nextpen:
            addq.l  #6,a2
            dbf     d6,.pen
            rts                         ; Fence, post or a full pen: no way through

;──────────────────────────────────────────────────────────────
; penglyph — stamp the resident-sheep glyph into PLANE 2
;   d0 = x (bytes). Row is PEN_ROW; the glyph is the HUD icon.
;──────────────────────────────────────────────────────────────
clearfold:
            lea     plane2,a0           ; The residents live in plane 2
            move.w  #PEN_ROW,d0         ;   — the farm-wide clear never
            mulu    #ROW_BYTES,d0       ;   touches them. New level,
            adda.w  d0,a0               ;   empty pens, BOTH planes.
            move.w  #8*ROW_BYTES/4-1,d1
.cl:        clr.l   (a0)+
            dbf     d1,.cl
            rts

penglyph:
            lea     plane2,a0
            move.w  #PEN_ROW,d4
            mulu    #ROW_BYTES,d4
            add.w   d0,d4
            adda.w  d4,a0
            lea     sheepicon,a2
            moveq   #8-1,d4
.row:
            move.b  (a2)+,(a0)
            lea     ROW_BYTES(a0),a0
            dbf     d4,.row
            rts

            ; Per pen: centre-x span (min, max), glyph byte
            ; column (high byte of the word), taken flag, pad
pentab:     dc.w    8,63
            dc.b    4,0
            even
            dc.w    72,127
            dc.b    12,0
            even
            dc.w    136,191
            dc.b    20,0
            even
            dc.w    200,255
            dc.b    28,0
            even
            dc.w    264,311
            dc.b    36,0
            even

;══════════════════════════════════════════════════════════════
; PLAYSOUND — start a sound on Paula channel 0
;   d0 = starting period   d1 = second period (from halfway)
;   d2 = duration (frames) d3 = volume (0-64)
;
; Paula plays a looping sample on its own DMA: point the
; channel at the wave, say how long it is and how fast to
; step through it (the period), set a volume, switch the DMA
; on. Everything after that is timing: soundtick slides the
; period at halfway and shuts the channel up when time runs
; out. New sounds steal the channel — the farmyard talks over
; itself rather than queueing politely.
;══════════════════════════════════════════════════════════════

playsound:
            lea     squarewave,a0
            move.l  a0,AUD0LC(a5)       ; The wave to loop
            move.w  #4,AUD0LEN(a5)      ; Four words = eight samples
            move.w  d0,AUD0PER(a5)      ; Pitch now...
            move.w  d1,sndper2          ; ...pitch later
            move.w  d3,AUD0VOL(a5)
            move.w  d2,sndtimer
            lsr.w   #1,d2
            move.w  d2,sndhalf          ; Where the wobble happens
            move.w  #$8001,DMACON(a5)   ; SET + AUD0EN: sing
            rts

;──────────────────────────────────────────────────────────────
; soundtick — once per frame: wobble at halfway, stop on time
;──────────────────────────────────────────────────────────────
soundtick:
            tst.w   sndtimer
            beq.s   .quiet
            subq.w  #1,sndtimer
            bne.s   .wobble
            move.w  #$0001,DMACON(a5)   ; CLR + AUD0EN: hush
            move.w  #0,AUD0VOL(a5)
            rts
.wobble:
            move.w  sndtimer,d0
            cmp.w   sndhalf,d0          ; Halfway through?
            bne.s   .quiet
            move.w  sndper2,AUD0PER(a5) ; The second note
.quiet:
            rts

;══════════════════════════════════════════════════════════════
; DRAWFLOCK — the sheep in hand, as icons on the HUD strip
;
; One 8x8 glyph per sheep still in hand, drawn at the bottom
; left; the strip is cleared first so a lost sheep disappears.
; The icons are bitplane pixels — the HUD band's COLOR01 makes
; them white, the same per-band trick as the fence and dashes.
;══════════════════════════════════════════════════════════════

drawflock:
            ; Clear the icon area (a row of byte-rectangles)
            moveq   #1,d0               ; From byte 1
            move.w  #ROW_HUD+4,d1
            moveq   #12,d2              ; Room for the whole flock
            moveq   #8,d3
            bsr     rectclear

            ; One glyph per sheep in hand
            move.w  lives,d7
            ble.s   .none               ; Empty hand, empty strip
            moveq   #1,d6               ; First icon at byte 1
.icons:
            move.w  d6,d0
            move.w  #ROW_HUD+4,d1
            lea     sheepicon,a2
            bsr     drawglyph
            addq.w  #2,d6               ; Two bytes along for the next
            subq.w  #1,d7
            bne.s   .icons
.none:
            rts

;──────────────────────────────────────────────────────────────
; drawglyph — copy an 8-row, 1-byte-wide glyph into the plane
;   d0 = x (bytes)   d1 = row   a2 = glyph (8 bytes)
;   Trashes d1, d4, a0.
;──────────────────────────────────────────────────────────────
drawglyph:
            lea     plane,a0
            move.w  d1,d4
            mulu    #ROW_BYTES,d4
            add.w   d0,d4
            adda.w  d4,a0
            moveq   #8-1,d4
.row:
            move.b  (a2)+,(a0)
            lea     ROW_BYTES(a0),a0
            dbf     d4,.row
            rts

;──────────────────────────────────────────────────────────────
; rectclear — rectfill's opposite: clear a byte-aligned block
;   d0 = x (bytes)   d1 = row   d2 = width (bytes)   d3 = height
;   Trashes d1, d4, d5, a0, a1.
;──────────────────────────────────────────────────────────────
rectclear:
            lea     plane,a0
            move.w  d1,d4
            mulu    #ROW_BYTES,d4
            add.w   d0,d4
            adda.w  d4,a0
            move.w  d3,d4
.row:
            movea.l a0,a1
            move.w  d2,d5
.col:
            clr.b   (a1)+
            subq.w  #1,d5
            bne.s   .col
            lea     ROW_BYTES(a0),a0
            subq.w  #1,d4
            bne.s   .row
            rts

sheepicon:  dc.b    %00100100           ; A sheep, in eight bytes:
            dc.b    %01111110           ;   ears up top,
            dc.b    %11111111           ;   a fat woolly middle,
            dc.b    %11111111
            dc.b    %11111111
            dc.b    %01111110
            dc.b    %00111100           ;   tapering to
            dc.b    %00011000           ;   a little tail
            even

;══════════════════════════════════════════════════════════════
; DRAWSCORE — four decimal digits at the strip's right end
;
; The score lives as one binary word; the display is decimal.
; DIVU by 10 peels the digits off the right: the remainder is
; the next digit, the quotient carries on. Stamp them right to
; left with the same drawglyph the icons use — each digit is
; just a glyph in the font table.
;══════════════════════════════════════════════════════════════

drawscore:
            move.w  score,d7            ; D7 = what's left to convert
            moveq   #38,d5              ; Rightmost digit's byte column
            moveq   #4-1,d6             ; Four digits
.digit:
            moveq   #0,d0
            move.w  d7,d0
            divu    #10,d0              ; Quotient low, remainder high
            move.l  d0,d1
            swap    d1                  ; D1 = this digit (0-9)
            move.w  d0,d7               ; D7 = the rest
            ; Find the digit's glyph: font + digit*8
            lea     digitfont,a2
            add.w   d1,d1
            add.w   d1,d1
            add.w   d1,d1               ; digit * 8
            adda.w  d1,a2
            move.w  d5,d0               ; Byte column
            move.w  #ROW_HUD+4,d1
            bsr     drawglyph
            subq.w  #1,d5               ; Next digit to the left
            dbf     d6,.digit
            rts

digitfont:  ; 0-9, one byte per row, eight rows each
            dc.b    %01111100,%11000110,%11001110,%11010110,%11100110,%11000110,%01111100,0  ; 0
            dc.b    %00011000,%00111000,%00011000,%00011000,%00011000,%00011000,%01111110,0  ; 1
            dc.b    %01111100,%11000110,%00000110,%00111100,%01100000,%11000000,%11111110,0  ; 2
            dc.b    %01111100,%11000110,%00000110,%00111100,%00000110,%11000110,%01111100,0  ; 3
            dc.b    %00011100,%00111100,%01101100,%11001100,%11111110,%00001100,%00001100,0  ; 4
            dc.b    %11111110,%11000000,%11111100,%00000110,%00000110,%11000110,%01111100,0  ; 5
            dc.b    %01111100,%11000000,%11111100,%11000110,%11000110,%11000110,%01111100,0  ; 6
            dc.b    %11111110,%00000110,%00001100,%00011000,%00110000,%00110000,%00110000,0  ; 7
            dc.b    %01111100,%11000110,%01111100,%11000110,%11000110,%11000110,%01111100,0  ; 8
            dc.b    %01111100,%11000110,%11000110,%01111110,%00000110,%00000110,%01111100,0  ; 9
            even

;══════════════════════════════════════════════════════════════
; COPPER LIST — the farmyard, plus eight sprite pointers
;══════════════════════════════════════════════════════════════

copperlist:
            ; --- Display setup ---
            dc.w    DIWSTRT,$2c81       ; Window: top-left
            dc.w    DIWSTOP,$2cc1       ; Window: bottom-right
            dc.w    DDFSTRT,$0038       ; Fetch start (lores)
            dc.w    DDFSTOP,$00d0       ; Fetch stop
            dc.w    BPLCON0,$2200       ; 2 bitplanes, colour burst on
            dc.w    BPLCON1,$0000       ; No scroll
            dc.w    BPLCON2,$0024       ; Sprites in front of playfield
            dc.w    BPL1MOD,$0000       ; No modulo — rows pack tight
            dc.w    BPL2MOD,$0000
copbpl:
            dc.w    BPL1PTH,$0000       ; Plane addresses, poked in
            dc.w    BPL1PTL,$0000       ;   by the CPU at startup
            dc.w    BPL2PTH,$0000
            dc.w    BPL2PTL,$0000

copsprites:
            dc.w    SPR0PTH+0,$0000     ; Sprite 0: the sheep (poked in)
            dc.w    SPR0PTH+2,$0000
            dc.w    SPR0PTH+4,$0000     ; Sprites 1-7: the null sprite
            dc.w    SPR0PTH+6,$0000
            dc.w    SPR0PTH+8,$0000
            dc.w    SPR0PTH+10,$0000
            dc.w    SPR0PTH+12,$0000
            dc.w    SPR0PTH+14,$0000
            dc.w    SPR0PTH+16,$0000
            dc.w    SPR0PTH+18,$0000
            dc.w    SPR0PTH+20,$0000
            dc.w    SPR0PTH+22,$0000
            dc.w    SPR0PTH+24,$0000
            dc.w    SPR0PTH+26,$0000
            dc.w    SPR0PTH+28,$0000
            dc.w    SPR0PTH+30,$0000

            ; --- Plane-2 colours: a resident sheep is white wherever
            ;     she settles (colour 2 = plane 2 alone; colour 3 = both
            ;     planes — fence-and-sheep never overlap, white is safe)
            dc.w    COLOR02,$0EEE
            dc.w    COLOR03,$0EEE

            ; --- The sheep's colours (sprites 0-1 share 17-19) ---
            ; Labelled: newsheep repaints these three words live
woolentry:  dc.w    COLOR17,COLOUR_WOOL
faceentry:  dc.w    COLOR18,COLOUR_FACE
shadeentry: dc.w    COLOR19,COLOUR_SHADE

            ; --- The tractor's colours (sprites 2-3 share 21-23) ---
            dc.w    COLOR21,COLOUR_TRACTOR
            dc.w    COLOR22,COLOUR_TYRE
            dc.w    COLOR23,COLOUR_CAB

            ; --- The hay cart's (sprites 4-5 share 25-27) ---
            dc.w    COLOR25,COLOUR_WOODWORK
            dc.w    COLOR26,COLOUR_TYRE
            dc.w    COLOR27,COLOUR_HAY

            ; --- The Land Rover's (sprites 6-7 share 29-31) ---
            dc.w    COLOR29,COLOUR_ROVER
            dc.w    COLOR30,COLOUR_TYRE
            dc.w    COLOR31,COLOUR_ROOF

            ; --- THE FOLD (from the top of the frame) ---
            dc.w    COLOR00,COLOUR_FOLD_GRASS
            dc.w    COLOR01,COLOUR_FENCE        ; Pixels here are fence

            ; --- HEDGEROW (row 40) ---
            dc.w    $5401,$fffe                 ; Wait: line $2C+40 = $54
            dc.w    COLOR00,COLOUR_HEDGE
            dc.w    COLOR01,COLOUR_TUFT

            ; --- THE STREAM (row 48) ---
            dc.w    $5c01,$fffe                 ; Wait: line $2C+48 = $5C
            dc.w    COLOR00,COLOUR_WATER
            dc.w    COLOR01,COLOUR_WOOD         ; Pixels here are bridge

            ; --- THE BANK (row 80) ---
            dc.w    $7c01,$fffe                 ; Wait: line $2C+80 = $7C
            dc.w    COLOR00,COLOUR_BANK
            dc.w    COLOR01,COLOUR_TUFT

            ; --- THE LANE (row 96) ---
            dc.w    $8c01,$fffe                 ; Wait: line $2C+96 = $8C
            dc.w    COLOR00,COLOUR_LANE
            dc.w    COLOR01,COLOUR_DASH         ; Pixels here are markings

            ; --- THE VERGE (row 160) ---
            dc.w    $cc01,$fffe                 ; Wait: line $2C+160 = $CC
            dc.w    COLOR00,COLOUR_VERGE
            dc.w    COLOR01,COLOUR_TUFT

            ; --- THE FIELD (row 176, down to row 239) ---
            dc.w    $dc01,$fffe                 ; Wait: line $2C+176
            dc.w    COLOR00,COLOUR_FIELD
            dc.w    COLOR01,COLOUR_TUFT

            ; --- THE HUD STRIP (row 240) ---
            ; Row 240 is beam line $11C — past 255, which the Copper's
            ; 8-bit comparator can't name directly. The classic trick:
            ; wait for the very end of line 255, THEN wait for the low
            ; byte. The first wait carries you across the boundary.
            dc.w    $ffdf,$fffe                 ; To the end of line 255
            dc.w    $1c01,$fffe                 ; Then line $11C & $FF = $1C
            dc.w    COLOR00,COLOUR_HUD
            dc.w    COLOR01,COLOUR_ICON

            ; --- END OF COPPER LIST ---
            dc.w    $ffff,$fffe                 ; Wait for impossible position

;══════════════════════════════════════════════════════════════
; THE SHEEP — sprite 0, two step images
;
; Same sheep, two pictures. Step image 0: front-left and
; back-right feet planted. Step image 1: the other diagonal,
; tail swung the other way. Alternate them as she hops and
; she waddles. The control words are written by updsprite.
;══════════════════════════════════════════════════════════════

            section data,data_c

sheep0:
            dc.w    0                   ; POS — written by updsprite
            dc.w    0                   ; CTL — written by updsprite

            ;        plane A (fleece)    plane B (face/shade/feet)
            dc.w    %0000000000000000,%0000100000010000  ; ..ears..
            dc.w    %0000000000000000,%0000011111100000  ; ..head..
            dc.w    %0000000000000000,%0000001111000000  ; ..face..
            dc.w    %0000111111110000,%0000000000000000  ; fleece ruff
            dc.w    %0011111111111100,%0000000000000000  ; shoulders
            dc.w    %0111111111111110,%1000000000000000  ; < front foot
            dc.w    %0111111111111110,%1001000000001000  ; < + flecks
            dc.w    %0111111111111110,%0000000000000000
            dc.w    %0111111111111110,%0000001001000000  ; shade flecks
            dc.w    %0111111111111110,%0000000000000001  ; back foot >
            dc.w    %0111111111111110,%0000100000010001  ; + flecks  >
            dc.w    %0011111111111100,%0000000000000000  ; haunches
            dc.w    %0011111111111100,%0000000000000000
            dc.w    %0001111111111000,%0000000000000000
            dc.w    %0000111111110000,%0000000000000000  ; rump
            dc.w    %0000000000000000,%0000001100000000  ; tail, left

            dc.w    0,0                 ; End of sprite

sheep1:
            dc.w    0                   ; POS — written by updsprite
            dc.w    0                   ; CTL — written by updsprite

            ;        plane A (fleece)    plane B (face/shade/feet)
            dc.w    %0000000000000000,%0000100000010000  ; ..ears..
            dc.w    %0000000000000000,%0000011111100000  ; ..head..
            dc.w    %0000000000000000,%0000001111000000  ; ..face..
            dc.w    %0000111111110000,%0000000000000000  ; fleece ruff
            dc.w    %0011111111111100,%0000000000000000  ; shoulders
            dc.w    %0111111111111110,%0000000000000001  ; front foot >
            dc.w    %0111111111111110,%0001000000001001  ; + flecks  >
            dc.w    %0111111111111110,%0000000000000000
            dc.w    %0111111111111110,%0000001001000000  ; shade flecks
            dc.w    %0111111111111110,%1000000000000000  ; < back foot
            dc.w    %0111111111111110,%1000100000010000  ; < + flecks
            dc.w    %0011111111111100,%0000000000000000  ; haunches
            dc.w    %0011111111111100,%0000000000000000
            dc.w    %0001111111111000,%0000000000000000
            dc.w    %0000111111110000,%0000000000000000  ; rump
            dc.w    %0000000000000000,%0000000011000000  ; tail, right

            dc.w    0,0                 ; End of sprite

;══════════════════════════════════════════════════════════════
; THE TRACTOR — sprite 2
;
; Big rear wheels on the left, small front wheels and the
; bonnet pointing right — the way it drives. Red bodywork,
; dark tyres, a grey cab roof. Its own palette: sprites 2-3
; share colours 21-23.
;══════════════════════════════════════════════════════════════

tractor:
            dc.w    0                   ; POS — written by updsprite
            dc.w    0                   ; CTL — written by updsprite

            ;        plane A (body/cab)   plane B (tyres/cab)
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0111110000000000  ; rear wheel
            dc.w    %0000000000000000,%0111110000011110  ; + front wheel
            dc.w    %0000000000000000,%0111110000011110
            dc.w    %0000001111111100,%0111110000000000  ; chassis
            dc.w    %0111111111111110,%0000111110000000  ; body + cab
            dc.w    %0111111111111110,%0000111110000000
            dc.w    %0111111111111110,%0000111110000000
            dc.w    %0111111111111110,%0000111110000000
            dc.w    %0000001111111100,%0111110000000000  ; chassis
            dc.w    %0000000000000000,%0111110000011110
            dc.w    %0000000000000000,%0111110000011110  ; + front wheel
            dc.w    %0000000000000000,%0111110000000000  ; rear wheel
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000

            dc.w    0,0                 ; End of sprite

nullspr:    dc.w    0,0                 ; A sprite that displays nothing
            dc.w    0,0

; --- The sheep's state ---
sheepx:     dc.w    SHEEP_X             ; Screen x (0-304)
sheepy:     dc.w    SHEEP_Y             ; Screen y (0-240)
cooldown:   dc.w    0                   ; Frames until the next hop
curframe:   dc.w    0                   ; Which step image: 0 or 1

;══════════════════════════════════════════════════════════════
; THE HAY CART — sprite 4
;
; Plods leftward: a wooden bed, a heaped load of hay, and
; wheels at the corners. Wood and hay get their own palette
; (sprites 4-5 share colours 25-27).
;══════════════════════════════════════════════════════════════

cart:
            dc.w    0                   ; POS — written by updsprite
            dc.w    0                   ; CTL — written by updsprite

            ;        plane A (wood/hay)   plane B (wheels/hay)
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0110000000000110  ; wheels
            dc.w    %0011111111111100,%0110000000000110
            dc.w    %0011111111111100,%0110000000000110
            dc.w    %0011111111111100,%0000111111110000  ; hay rises
            dc.w    %0011111111111100,%0001111111111000
            dc.w    %0011111111111100,%0001111111111000
            dc.w    %0011111111111100,%0001111111111000
            dc.w    %0011111111111100,%0001111111111000
            dc.w    %0011111111111100,%0000111111110000  ; hay falls
            dc.w    %0011111111111100,%0110000000000110
            dc.w    %0011111111111100,%0110000000000110  ; wheels
            dc.w    %0000000000000000,%0110000000000110
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000

            dc.w    0,0                 ; End of sprite

;══════════════════════════════════════════════════════════════
; THE LAND ROVER — sprite 6
;
; The farmer's in a hurry. Boxy paintwork, a roof panel set
; back from the bonnet (it drives leftward, so the bonnet is
; the left end), wheels at the corners. Sprites 6-7 share
; colours 29-31.
;══════════════════════════════════════════════════════════════

rover:
            dc.w    0                   ; POS — written by updsprite
            dc.w    0                   ; CTL — written by updsprite

            ;        plane A (paint/roof)  plane B (wheels/roof)
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0011000000001100  ; wheels
            dc.w    %0111111111111110,%0011000000001100
            dc.w    %0111111111111110,%0011000000001100
            dc.w    %0111111111111110,%0000001111111000  ; roof panel,
            dc.w    %0111111111111110,%0000001111111000  ;   set back
            dc.w    %0111111111111110,%0000001111111000  ;   from the
            dc.w    %0111111111111110,%0000001111111000  ;   bonnet
            dc.w    %0111111111111110,%0000001111111000
            dc.w    %0111111111111110,%0000001111111000
            dc.w    %0111111111111110,%0011000000001100
            dc.w    %0111111111111110,%0011000000001100  ; wheels
            dc.w    %0000000000000000,%0011000000001100
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000

            dc.w    0,0                 ; End of sprite

;══════════════════════════════════════════════════════════════
; THE HAY BALE — sprite 5
;
; A round bale adrift: hay (the cart-pair's colour 3) bound
; with two woodwork-brown straps (colour 1). Plane A alone is
; the straps; both planes together are the hay.
;══════════════════════════════════════════════════════════════

bale:
            dc.w    0                   ; POS — written by updsprite
            dc.w    0                   ; CTL — written by updsprite

            ;        plane A (straps+hay)  plane B (hay)
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000011111100000,%0000011111100000
            dc.w    %0001111111111000,%0001111111111000
            dc.w    %0011111111111100,%0011101111011100  ; straps read
            dc.w    %0111111111111110,%0111101111011110  ;   as thin
            dc.w    %0111111111111110,%0111101111011110  ;   brown lines
            dc.w    %0111111111111110,%0111101111011110
            dc.w    %0111111111111110,%0111101111011110
            dc.w    %0111111111111110,%0111101111011110
            dc.w    %0111111111111110,%0111101111011110
            dc.w    %0111111111111110,%0111101111011110
            dc.w    %0111111111111110,%0111101111011110
            dc.w    %0011111111111100,%0011101111011100
            dc.w    %0001111111111000,%0001111111111000
            dc.w    %0000011111100000,%0000011111100000
            dc.w    %0000000000000000,%0000000000000000

            dc.w    0,0                 ; End of sprite

duck:
            dc.w    0                   ; POS — written by updsprite
            dc.w    0                   ; CTL — written by updsprite

            ;        plane A               plane B   (green head, pale flank)
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000110000000000,%0000000000000000
            dc.w    %0011111000000000,%0000000000000000
            dc.w    %0111011000000000,%0110100000000000
            dc.w    %0011111000000000,%0000000000000000
            dc.w    %0001110000000000,%0000000000000000
            dc.w    %0001100011110000,%0000000011110000
            dc.w    %0001111111111100,%0000011111111100
            dc.w    %0011111111110000,%0011111111111100
            dc.w    %0011111111110000,%0011111111111100
            dc.w    %0011111111111000,%0011111111111000
            dc.w    %0001111111110000,%0001111111110000
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000

            dc.w    0,0                 ; End of sprite

duckwarn:
            dc.w    0                   ; POS — written by updsprite
            dc.w    0                   ; CTL — written by updsprite

            ;        plane A               plane B   (bottoms up — fair warning)
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000001000000
            dc.w    %0000000000000000,%0000000011000000
            dc.w    %0000000000000000,%0000000011000000
            dc.w    %0000001111000000,%0000001111000000
            dc.w    %0000011111100000,%0000011111100000
            dc.w    %0000111111110000,%0000111111110000
            dc.w    %0000111111110000,%0000111111110000
            dc.w    %0000111111110000,%0000111111110000
            dc.w    %0000011111100000,%0000011111100000
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000

            dc.w    0,0                 ; End of sprite

cow:
            dc.w    0                   ; POS — written by updsprite
            dc.w    0                   ; CTL — written by updsprite

            ;        plane A               plane B   (hide, patches, blaze+udder)
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000000000
            dc.w    %0000000000000000,%0000000000110110
            dc.w    %0111111111100000,%0000000000011100
            dc.w    %1111111111100110,%0000000000011110
            dc.w    %1100011111100100,%0011100000011100
            dc.w    %1000001111110000,%0111110000001000
            dc.w    %1100011111111000,%0011100000000000
            dc.w    %1111111111111000,%0000000000000000
            dc.w    %1111111111111000,%0000000000000000
            dc.w    %0111111111111000,%0000000000000000
            dc.w    %0000011100000000,%0011011100110000
            dc.w    %0000011100000000,%0011011100110000
            dc.w    %0000000000000000,%0011000000110000
            dc.w    %0000000000000000,%0111000001110000
            dc.w    %0000000000000000,%0000000000000000

            dc.w    0,0                 ; End of sprite

; --- The traffic's state ---
tractx:     dc.l    -16<<16             ; The tractor enters from the left
cartx:      dc.l    300<<16             ; The cart from the right
roverx:     dc.l    160<<16             ; The Rover mid-lane, flat out
balex:      dc.l    40<<16              ; The bale, already adrift
duckx:      dc.l    300<<16             ; The duck, paddling west
cowx:       dc.l    20<<16              ; The cow, in no hurry at all
duckstate:  dc.w    0                   ; 0 paddle, 1 warn, 2 under
framecnt:   dc.w    0                   ; Frames since the farm woke
seed:       dc.w    $ACE1               ; The xorshift state
isblack:    dc.w    0                   ; Is THIS sheep the gamble?
nerve:      dc.w    0                   ; Frames since her last hop
fretted:    dc.w    0                   ; The worried baa, played once
panic:      dc.w    0                   ; Involuntary hops remaining
gamestate:  dc.w    0                   ; 0 title, 1 playing
firewas:    dc.w    0                   ; Fire edge detector
endtimer:   dc.w    0                   ; Frames since the ending
jinglep:    dc.l    jingle              ; Next note to serve
jingletimer: dc.w   0                   ; Frames left on this note
level:      dc.w    1                   ; Which row of leveltab rules
duckpaddle: dc.w    DUCK_PADDLE         ; This level's duck stamina
nervebolt:  dc.w    NERVE_BOLT          ; This level's bolt threshold
hopbuf:     dc.w    0                   ; A tap banked mid-cooldown
sawneutral: dc.w    0                   ; Stick seen centred since hop

; One row per level: tractor, cart, Rover (16.16 — halves are
; real speeds now), duck paddle frames, bolt threshold.
leveltab:
            dc.l    2<<16,  -1<<16,    -3<<16
            dc.w    220, 250
            dc.l    (5<<16)/2, -(3<<16)/2, -(7<<16)/2
            dc.w    190, 220
            dc.l    3<<16,  -2<<16,    -4<<16
            dc.w    160, 190
            dc.l    (7<<16)/2, -(5<<16)/2, -(9<<16)/2
            dc.w    130, 160

; FLOCK in block capitals: (x byte, row, width bytes, height rows)
; Letters 3 bytes (24px) wide on a 4-byte pitch, rows 104-131.
titletab:
            ; F
            dc.w    10,112,1,28
            dc.w    10,112,3,4
            dc.w    10,124,2,4
            ; L
            dc.w    14,112,1,28
            dc.w    14,136,3,4
            ; O
            dc.w    18,112,1,28
            dc.w    20,112,1,28
            dc.w    18,112,3,4
            dc.w    18,136,3,4
            ; C
            dc.w    22,112,1,28
            dc.w    22,112,3,4
            dc.w    22,136,3,4
            ; K
            dc.w    26,112,1,28
            dc.w    28,112,1,8
            dc.w    27,120,1,8
            dc.w    28,128,1,12
            dc.w    -1

; Baa Baa Black Sheep, one phrase at a time: period, frames.
; 0 period = a rest; -1 = back to the top.
jingle:
            dc.w    NOTE_C,18, NOTE_C,18, NOTE_G,18, NOTE_G,18
            dc.w    NOTE_A,9,  NOTE_A,9,  NOTE_A,9,  NOTE_A,9
            dc.w    NOTE_G,32, 0,14
            dc.w    NOTE_F,18, NOTE_F,18, NOTE_E,18, NOTE_E,18
            dc.w    NOTE_D,9,  NOTE_D,9,  NOTE_D,9,  NOTE_D,9
            dc.w    NOTE_C,32, 0,60
            dc.w    -1
hopgap:     dc.w    COOLDOWN            ; This sheep's hop rhythm
ducktimer:  dc.w    DUCK_PADDLE         ; Frames left in this state
contacts:   dc.w    0                   ; This frame's CLXDAT, shared
drownarm:   dc.w    0                   ; Contactless wet frames so far

; --- The squash beat ---
squashtimer: dc.w   0                   ; Frames of stillness remaining

; --- The flock ---
lives:      dc.w    FLOCK_SIZE          ; Sheep in hand
gameover:   dc.w    0                   ; 1 = the field is empty
won:        dc.w    0                   ; 1 = every pen is full
unpenned:   dc.w    5                   ; Pens still to fill
score:      dc.w    0                   ; Points so far
roadflag:   dc.w    0                   ; This sheep has crossed the road

; --- The voice ---
sndtimer:   dc.w    0                   ; Frames of sound remaining
sndhalf:    dc.w    0                   ; When to slide the pitch
sndper2:    dc.w    0                   ; The pitch to slide to

squarewave: dc.b    64,64,64,64,-64,-64,-64,-64   ; One cycle, eight samples
            even

;══════════════════════════════════════════════════════════════
; THE BITPLANE (Chip RAM)
;══════════════════════════════════════════════════════════════

plane:      ds.b    ROW_BYTES*256       ; Plane 1: fence, bridge, dashes, icons
plane2:     ds.b    ROW_BYTES*256       ; Plane 2: the fold's residents
