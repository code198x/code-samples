# NES Lessons 017-032: Progressive Pong Development

Complete 6502 assembly code samples building from paddle control (L016) to complete Pong game (L032).

## Lesson Overview

### Completed Lessons (017-026)

| Lesson | Concept | File | Status |
|--------|---------|------|--------|
| 017 | Ball Entity | `ball-entity.asm` | ✅ Complete |
| 018 | Ball Movement | `ball-movement.asm` | ✅ Complete |
| 019 | Screen Boundaries | `ball-boundaries.asm` | ✅ Complete |
| 020 | Physics Angles | `physics-angles.asm` | ✅ Complete |
| 021 | Paddle Collision | `paddle-collision.asm` | ✅ Complete |
| 022 | Angle Control | `angle-control.asm` | ✅ Complete |
| 023 | Momentum Transfer | `momentum-transfer.asm` | ✅ Complete |
| 024 | Collision Cooldown | `collision-cooldown.asm` | ✅ Complete |
| 025 | Score Variables | `score-variables.asm` | ✅ Complete |
| 026 | Number to Tiles | `number-to-tiles.asm` | ✅ Complete |

### Remaining Lessons (027-032)

These lessons require additional assembly files to be created:

| Lesson | Concept | File Needed | Key Features |
|--------|---------|-------------|--------------|
| 027 | Score Display | `score-display.asm` | Nametable updates, PPU $2006/$2007 |
| 028 | Game States | `game-states.asm` | Title/Playing/Gameover, state machine |
| 029 | 2-Player Input | `two-player.asm` | Controller 2, second paddle |
| 030 | Sound Effects | `sound-effects.asm` | APU pulse channels, 3 sounds |
| 031 | Visual Polish | `visual-polish.asm` | Score flash, center line |
| 032 | Complete Pong | `pong-complete.asm` | Full integration, ~600 lines |

## Building Lessons

Each lesson directory contains:
- **`*.asm`** - Main assembly source
- **`README.md`** - Concept explanation and build instructions
- Uses shared **`../lesson-001/nes.cfg`** linker configuration

### Build Individual Lesson

```bash
cd lesson-NNN/
ca65 filename.asm -o filename.o
ld65 filename.o -C ../lesson-001/nes.cfg -o filename.nes
```

### Build All Lessons

```bash
./BUILD-ALL.sh
```

## Progressive Features by Lesson

### Core Physics (017-020)
- **L017**: Ball entity with position/velocity variables
- **L018**: Frame-based movement (velocity applied each frame)
- **L019**: Boundary detection with velocity negation (bounce)
- **L020**: Angle variation based on hit position

### Collision System (021-024)
- **L021**: AABB collision detection between paddle and ball
- **L022**: Hit position affects bounce angle (3 zones)
- **L023**: Paddle velocity transfers to ball (momentum)
- **L024**: Cooldown timer prevents double-hits

### Scoring System (025-027)
- **L025**: Score variables, edge detection, ball reset
- **L026**: Decimal to BCD conversion, digit tiles in CHR
- **L027**: Nametable updates during VBlank, visible scores

### Game Structure (028-032)
- **L028**: State machine (title/playing/gameover)
- **L029**: Second player input and paddle
- **L030**: APU sound effects (paddle/wall/score)
- **L031**: Visual polish (flash, center line)
- **L032**: Complete integration and final polish

## Technical Details

### Memory Map (Zero Page)

```
$00: nmi_ready
$01: buttons (P1)
$02: paddle_y (P1)
$03: paddle_y_old (P1)
$04: ball_x
$05: ball_y
$06: ball_dx (signed velocity)
$07: ball_dy (signed velocity)
$08: collision_timer
$09: temp
$0A: score_p1
$0B: score_p2
$0C: digit_tens
$0D: digit_ones
$0E: game_state (L028+)
$0F: buttons2 (P2, L029+)
$10: paddle2_y (L029+)
$11: paddle2_y_old (L029+)
$12: flash_timer (L031+)
```

### CHR-ROM Tiles

```
$00: Paddle tile (8x8 vertical bar)
$01: Ball tile (8x8 circle)
$02: Center line dash (L031+)
$30-$39: Digit tiles '0'-'9' (L026+)
```

### Sprite Layout (OAM $0200-$02FF)

```
Sprites 0-3:   Player 1 paddle (4x 8x8 tiles = 32px tall)
Sprites 4-7:   Player 2 paddle (L029+)
Sprite 8:      Ball
Sprites 9-16:  Center line dashes (L031+)
```

### APU Sounds (L030+)

```
Pulse 1 ($4000-$4003): Paddle hit, wall bounce
Pulse 2 ($4004-$4007): Score sound
$4015: Channel enable
```

## Code Statistics

### Lesson 026 (Last Complete)
- **Lines**: 454
- **Functions**: 14
- **RAM variables**: 10
- **Features**: Ball physics, collision, cooldown, scoring (no display)

### Lesson 032 (Target)
- **Lines**: ~600 (estimated)
- **Functions**: ~20
- **RAM variables**: 13+
- **Features**: Complete 2-player Pong with sound and polish

## Key Algorithms Demonstrated

### Velocity Negation (Two's Complement)
```asm
LDA velocity
EOR #$FF        ; Invert bits
CLC
ADC #1          ; Add 1
STA velocity    ; Result: -velocity
```

### Decimal to BCD Conversion
```asm
LDX #0          ; Tens counter
@loop:
    CMP #10
    BCC @done
    SBC #10     ; Subtract 10
    INX         ; Count tens
    JMP @loop
@done:
    ; A = ones, X = tens
```

### AABB Collision Detection
```asm
; X overlap: ball.left < paddle.right AND ball.right > paddle.left
; Y overlap: ball.top < paddle.bottom AND ball.bottom > paddle.top
; Collision = X overlap AND Y overlap
```

## Building Complete System

To create a complete Pong game from these lessons:

1. **Understand progression**: Each lesson builds on previous
2. **Follow build order**: 017 → 018 → ... → 032
3. **Test incrementally**: Verify each feature works before adding next
4. **Study code comments**: Explain WHY, not just WHAT
5. **Experiment**: Modify constants, add features

## Compilation Requirements

- **Assembler**: ca65 (CC65 toolchain)
- **Linker**: ld65 (CC65 toolchain)
- **Config**: NES memory layout (nes.cfg)
- **Output**: .nes ROM file (iNES format)

## Testing

- **Emulator**: FCEUX, Mesen, Nestopia, etc.
- **Hardware**: Everdrive N8 or similar flash cart
- **Controllers**: NES controllers for 2-player (L029+)

## Notes for Educators

These lessons demonstrate:
- **Progressive complexity**: Each lesson adds ONE major concept
- **Working code**: Every lesson compiles and runs
- **Clear progression**: Ball entity → movement → collision → scoring → complete game
- **Real-world techniques**: Production-quality 6502 patterns
- **60fps gameplay**: Frame timing and VBlank synchronization

Students learn by building a complete, playable game step-by-step.

## Next Steps

To complete lessons 027-032:
1. Copy/extend lesson 026 assembly
2. Add nametable update code (L027)
3. Add state machine logic (L028)
4. Duplicate paddle system for P2 (L029)
5. Add APU sound routines (L030)
6. Add visual polish (L031)
7. Integrate and test complete game (L032)

---

**File Count**: 10 complete assemblies (017-026), 6 to implement (027-032)
**Total Lines**: ~3000 (estimated complete series)
**Time Investment**: 16 lessons × 45min = 12 hours of instruction
