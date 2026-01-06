# Unit 10: Enemy Sprite

Add an enemy alien to the playfield.

## What This Unit Covers

- Third sprite type (enemy)
- Enemy sprite graphics
- Initial enemy positioning

## Key Concepts

| Concept | Description |
|---------|-------------|
| Sprite slot | Sprite 5 for first enemy |
| Enemy colour | Different from player/bullet |
| Enemy state | Active flag, position |

## Enemy Design

Classic space invader silhouette:

```
..#......#..
...#....#...
..########..
.##.####.##.
############
#.########.#
#.#......#.#
...##..##...
```

## Expected Result

Enemy alien sprite appears at top of screen.

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
