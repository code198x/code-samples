# Lesson 003: Dungeon Quest

Complete text adventure game with procedures and state management.

## Files

- `dungeon-quest.amos` - Three-room adventure with key and scoring

## Concepts

- **Procedures**: Named code blocks (`Proc...End Proc`)
- **State variables**: Track room, inventory, score
- **Game loop**: `Do...Loop Until` with exit condition
- **Procedure calls**: Execute procedure by name (no GOSUB)
- **Multiple conditionals**: Check state and respond appropriately
- **Add command**: Increment variables (`Add score,10`)

## Game Structure

**Rooms:**
1. Dark Cave Entrance - Starting point
2. Treasure Chamber - Contains golden key
3. Dragon's Lair - Final challenge (needs key)

**Commands:**
- `N` - Move north
- `S` - Move south
- `T` - Take item
- `Q` - Quit game

**Goal:** Collect the key from Room 2, then unlock treasure in Room 3.

## Key Points

AMOS procedures:
- Define with `Procedure Name`
- End with `End Proc`
- Call by name (no brackets, no GOSUB)
- Can access all variables (global scope)
- Ideal for organizing game logic by room or action

## Running

1. Load AMOS Professional
2. Load `dungeon-quest.amos`
3. Press F1 to run
4. Use commands to explore and solve puzzle
5. Press Q to quit anytime

## Extensions

Try adding:
- More rooms (4-10 room dungeon)
- Multiple items in inventory
- Combat system with health points
- Random encounters
- Save/load game state
- ASCII map display
- Time limit or move counter
- Multiple endings based on choices
