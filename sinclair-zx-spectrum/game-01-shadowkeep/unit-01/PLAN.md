# Unit Plan: sinclair-zx-spectrum/game-01-shadowkeep/unit-01

## Learning Objectives

From the curriculum:
- Write `LD A,n` and `LD (addr),A` (and `LD HL,addr` / `LD (HL),n`)
- Understand memory addresses — specifically attribute memory at $5800
- See a colour on screen by writing to attribute memory
- Understand the attribute byte format (FBPPPIII)

## Prerequisites

None. This is the first unit of the first game. The learner has set up their
toolchain (pasmonext assembler, Fuse emulator) following the Getting Started
guide.

## Approach

**Minimal.** The curriculum says Unit 1 = "coloured block on screen." No loops,
no keyboard, no movement. Just LD instructions and attribute writes. Build
understanding from the absolute simplest visible result.

Matches the pattern of C64 Starfield unit-01 ("Ship on Screen") — one concept,
immediate visual payoff, "Try This" experiments to explore.

## Steps

### Step 1: The Empty Program
**Concept:** Toolchain verification — assembler, emulator, the build cycle
**Code changes:**
- `org 32768` and `ret` — the simplest possible Z80 program
- Build with pasmonext, load in Fuse
- Nothing visible happens — that's expected
**Snippet:** `01-empty.asm` (3 lines)
**Screenshot:** No — blank screen, nothing to show

### Step 2: Set the Border
**Concept:** `LD A,n` (load immediate) and `OUT (port),A` (write to hardware)
**Code changes:**
- `ld a, 1` — load blue into A
- `out ($fe), a` — write to border port
- `halt` + `jr $-1` — infinite loop so the program doesn't return to BASIC
**Snippet:** `02-border.asm` (~8 lines)
**Screenshot:** Yes — blue border, black screen

### Step 3: One Coloured Cell
**Concept:** `LD HL,addr` / `LD (HL),n` — writing to a specific memory address
**Code changes:**
- `ld hl, $5800 + (12 * 32) + 16` — centre of attribute grid
- `ld (hl), $30` — yellow PAPER (6 << 3 = 48 = $30)
- The cell turns yellow on the black screen
**Snippet:** `03-one-cell.asm` (~12 lines)
**Screenshot:** Yes — single yellow cell in centre of black screen

### Step 4: The Attribute Byte
**Concept:** FBPPPIII format — what each bit does
**Code changes:**
- No new code — this is an explanation section
- Diagram of the attribute byte
- Table of the 8 basic colours
- Explanation of how $30 = yellow paper, black ink
**Snippet:** None
**Screenshot:** None

### Step 5: Multiple Cells — Walls and Floor
**Concept:** Writing multiple attribute addresses to create a pattern
**Code changes:**
- Write blue (INK 1) cells as "walls" around the edges of a small area
- Write white (PAPER 7) cells as "floor" inside
- 6-8 manual `ld hl` / `ld (hl)` pairs — no loops yet
- The first glimpse of a room takes shape
**Snippet:** `04-walls-and-floor.asm` (~30 lines)
**Screenshot:** Yes — small cluster of coloured cells forming a room-like shape

### Step 6: Try This Experiments
**Concept:** Hands-on exploration of attribute values
**Code changes:** None — modification prompts only
- **Try This: Change the Wall Colour** — change INK bits (0-2) from 1 (blue) to other values
- **Try This: Add BRIGHT** — set bit 6 on some cells
- **Try This: Add FLASH** — set bit 7 to make a cell flash (foreshadowing hazards)
- **Try This: Work Out an Address** — calculate $5800 + (row × 32) + col by hand
**Snippet:** None
**Screenshot:** None (learner experiments)

### Step 7: The Complete Program
**Concept:** Putting it all together — border + attribute writes = a visible scene
**Code changes:**
- Complete `shadowkeep.asm` — all attribute writes in one program
- Clears attributes to black first (using LDIR — shown but not explained in depth, "we'll explore loops properly in Unit 3")
- Sets border to black
- Writes wall cells (blue INK) and floor cells (white PAPER)
- Adds one BRIGHT cell (treasure preview) and one FLASH cell (hazard preview)
- Infinite loop at end
**Snippet:** `05-complete.asm` (the final code for this unit, ~50-60 lines)
**Screenshot:** Yes — the unit's final result: a small room shape with coloured cells

## Narrative Flow

1. Build and run (proves the tools work)
2. Blue border (first visible change — "you control the hardware")
3. One yellow cell (the "aha" — writing to memory changes the screen)
4. What the byte means (understanding follows experience)
5. Multiple cells forming a room (attributes as game world)
6. Experiments (ownership — the learner makes their own changes)
7. Complete code (reference listing)

## Notes

- **No loops** — Unit 3 introduces DJNZ for drawing rooms from data
- **No keyboard** — Unit 4 introduces IN A,(port) for input
- **No movement** — Unit 6 introduces character-cell movement
- The LDIR in the screen clear is shown but explicitly deferred: "We'll explain this loop instruction in Unit 3. For now, just know it fills memory."
- The room shape is deliberately crude (just a few manually-placed cells) to motivate the loop-based approach in Unit 3
- Attribute address calculation ($5800 + row*32 + col) is taught here and used throughout the entire game

## Code Files

```
code-samples/sinclair-zx-spectrum/game-01-shadowkeep/unit-01/
├── shadowkeep.asm          # Complete working program
├── Makefile                # Build automation
├── PLAN.md                 # This file
└── snippets/
    ├── 01-empty.asm        # Step 1: minimal program
    ├── 02-border.asm       # Step 2: border colour
    ├── 03-one-cell.asm     # Step 3: single attribute write
    ├── 04-walls-and-floor.asm  # Step 5: multiple attributes
    └── 05-complete.asm     # Step 7: full program (= shadowkeep.asm)
```
