# Ink War

A territory control game for the ZX Spectrum that teaches Z80 assembly programming through incremental game development.

## Overview

Ink War is a turn-based strategy game where players compete to claim territory on an 8x8 board. Players can claim neutral cells or convert adjacent enemy cells. The game features AI opponents with multiple difficulty levels and two-player hotseat mode.

## Controls

- **Q** - Move cursor up
- **A** - Move cursor down
- **O** - Move cursor left
- **P** - Move cursor right
- **SPACE** - Claim cell / confirm selection

## Building

Requires [pasmonext](https://pasmo.speccy.org/) assembler.

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

Or use the provided Docker container:

```bash
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  ghcr.io/code198x/sinclair-zx-spectrum:latest \
  pasmonext --tapbas inkwar.asm inkwar.tap
```

## Unit Progression

| Unit | Title | Features Introduced |
|------|-------|---------------------|
| 01 | The Board | Screen setup, attribute memory, board drawing |
| 02 | The Cursor | Cursor display, attribute highlighting |
| 03 | Movement | Keyboard scanning, cursor movement |
| 04 | Claiming Cells | Cell ownership, player claims |
| 05 | Turn Logic | Turn-based system, player switching |
| 06 | Valid Moves | Adjacency checking, move validation |
| 07 | Simple AI | Random AI move selection |
| 08 | Better AI | Strategic AI with scoring heuristics |
| 09 | Win Detection | Game-over condition, winner determination |
| 10 | Scoring | Territory counting, score display |
| 11 | Sound Effects | Beeper sound generation |
| 12 | Title Screen | Title display, game states |
| 13 | Two Player Mode | Human vs human gameplay |
| 14 | Difficulty Levels | Easy/Normal/Hard AI settings |
| 15 | Visual Polish | Border effects, animations |
| 16 | Final Game | Complete polished version |

## Learning Objectives

### Phase 1: Foundation (Units 1-4)
- ZX Spectrum screen memory layout
- Attribute memory for colour control
- Z80 register operations
- ROM routine usage (RST 16, CLS)

### Phase 2: Interaction (Units 5-8)
- Keyboard matrix scanning via IN instruction
- Turn-based game logic
- Move validation algorithms
- Basic AI decision-making

### Phase 3: Game Logic (Units 9-12)
- Win condition detection
- Score calculation
- Beeper sound generation
- Game state management

### Phase 4: Polish (Units 13-16)
- Multiple game modes
- Difficulty configuration
- Visual feedback effects
- Code organisation

## Hardware Used

- **ULA**: Screen display, attribute memory, border colour, keyboard scanning
- **Beeper**: Sound generation via OUT (254)

## File Structure

Each unit contains:
- `inkwar.asm` - Main assembly source
- `inkwar.tap` - TAP file for emulators
