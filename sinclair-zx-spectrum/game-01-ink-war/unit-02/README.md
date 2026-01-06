# Unit 2: The Cursor

Cursor display with attribute highlighting.

## What This Unit Covers

- Cursor position tracking with variables
- Attribute memory address calculation
- Visual highlighting via colour change
- Cell-to-memory address mapping

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator. The cursor appears as a highlighted cell on the board.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Cursor variables | cursor_x, cursor_y track position |
| Address calculation | row * 32 + column + base address |
| Highlight effect | Change attribute to show selection |
| Cell mapping | Game coordinates to screen addresses |

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
