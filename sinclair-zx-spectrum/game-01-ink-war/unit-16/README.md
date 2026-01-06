# Unit 16: Final Game

Complete polished version with all features.

## What This Unit Covers

- Code organisation and documentation
- All features integrated
- Production-ready game
- Complete gameplay loop

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator.

### Controls

| Key | Action |
|-----|--------|
| Q | Move cursor up |
| A | Move cursor down |
| O | Move cursor left |
| P | Move cursor right |
| SPACE | Claim cell / confirm |

## Complete Feature List

- 8x8 territory control gameplay
- Turn-based player vs player or AI
- Three AI difficulty levels (Easy/Normal/Hard)
- Two-player hotseat mode
- Move validation with adjacency rules
- Live score display
- Win detection and celebration
- Sound effects for game events
- Visual feedback animations
- Full game loop (title, play, result)

## Game Modes

| Mode | Description |
|------|-------------|
| 1 Player Easy | Human vs weak AI |
| 1 Player Normal | Human vs moderate AI |
| 1 Player Hard | Human vs strategic AI |
| 2 Player | Human vs Human |

## Code Organisation

1. **Constants** - Memory addresses, colours, keyboard
2. **Entry point** - Initialisation and state dispatch
3. **Screen routines** - Drawing and clearing
4. **Input handling** - Keyboard scanning
5. **Game logic** - Board, moves, turns
6. **AI routines** - Move selection and scoring
7. **Sound** - Beeper effects
8. **Data** - Text strings, board state

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
