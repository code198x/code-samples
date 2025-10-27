# ZX Spectrum Lesson 016 - Spectrum Survivor

## Files

- `simple-survivor.bas` - Complete game structure demonstration
- `spectrum-survivor.bas` - Full synthesis game with all Tier 1 concepts

## Running the Code

### On Real Hardware
1. Switch on your ZX Spectrum
2. Type in the program line by line
3. Type `RUN` and press ENTER

### On Emulator (Fuse, ZXSpin, etc.)
1. Start the emulator
2. Type in the program or load the .bas file
3. Type `RUN` and press ENTER

## What It Does

### simple-survivor.bas
Demonstrates complete game structure:
- Title screen with instructions
- Game initialization
- Main game loop combining all systems
- Victory condition (collect all stars)
- Game over condition (lose all lives)
- Lives system with position reset
- 5 collectible stars
- 1 chasing enemy
- Open playfield (no maze)

### spectrum-survivor.bas
Full synthesis of all Tier 1 concepts:
- Professional title screen
- Complex maze with multiple rooms
- 6 collectible gold pieces
- 2 independent chasing enemies
- Lives system (3 lives)
- Increasing difficulty (speeds up after collecting 3 gold)
- Victory screen showing remaining lives
- Game over screen with contextual messages
- Position reset after death
- Status display (gold count, lives)
- Sound effects for all actions
- Complete game flow from start to finish

## Key Concepts (Tier 1 Synthesis)

This lesson combines everything from Phase 0, Tier 1:

1. **PRINT AT** - Positioning text and graphics (lessons 2-6)
2. **INPUT and IF...THEN** - User interaction and logic (lesson 2)
3. **GOSUB/RETURN** - Code organization (lesson 3)
4. **READ/DATA** - Not used in this game, but mastered in lesson 4
5. **Arrays (DIM)** - Not used in this game, but mastered in lesson 6
6. **PLOT/DRAW/CIRCLE** - Not used (character-based graphics) but mastered in lessons 7-8
7. **INK/PAPER/BRIGHT** - Colour system (lessons 8-9)
8. **BEEP** - Sound effects (lessons 10-11)
9. **INKEY$** - Non-blocking input (lesson 12)
10. **SCREEN$** - Collision detection (lesson 13)
11. **Scoring** - Game state tracking (lesson 14)
12. **Enemy AI** - Chase algorithm (lesson 15)
13. **Lives system** - Mistake tolerance (lesson 15)
14. **Complete game structure** - Title/Play/End flow (lesson 16)

## Controls

### Both Programs
- Q - Move up
- A - Move down
- O - Move left
- P - Move right
- Collect all gold to win
- Avoid enemies or lose lives

## Game Flow

### simple-survivor.bas
1. Title screen - press any key
2. Initialize game (score=0, lives=3, items=5)
3. Place 5 stars on screen
4. Place player and 1 enemy
5. Game loop:
   - Player input (QAOP)
   - Check destination (collect or move)
   - Enemy AI (chase player)
   - Check collision (lose life if caught)
   - Check win (all items collected)
   - Check game over (lives=0)
6. Victory or game over screen

### spectrum-survivor.bas
1. Professional title screen with instructions
2. Draw complex maze
3. Initialize game (score=0, lives=3, items=6, speed=3)
4. Place 6 gold pieces in strategic locations
5. Place player and 2 enemies
6. Game loop:
   - Player input (QAOP)
   - Check destination (collect or move)
   - Enemy 1 AI (chase through maze)
   - Enemy 2 AI (chase through maze)
   - Check collisions with both enemies
   - Check win (all gold collected)
   - Check game over (lives=0)
   - Increase difficulty after 3 gold collected
7. Victory screen (shows remaining lives) or Game over screen (contextual messages based on score)

## Technical Features

- **Title screen**: Sets tone, provides instructions, waits for input
- **Multiple enemies**: Each with independent position tracking and AI
- **Difficulty progression**: SPEED variable decreases when SCORE=3 (faster gameplay)
- **Contextual feedback**: Different game over messages based on performance
- **Professional structure**: Clear separation of initialization, game loop, and endings
- **Complete subroutine organization**:
  - 1000s: Collection
  - 2000s: Movement
  - 3000s: Death handling
  - 4000s: Victory
  - 5000s: Game over
  - 6000s: Position reset
- **Sound design**: Different BEEPs for collection, death, victory
- **Visual hierarchy**: BRIGHT colours for important messages
- **Status display**: Always visible progress indicators

## Increasing Difficulty

```basic
2080 REM Increase difficulty
2090 IF SCORE=3 AND SPEED>1 THEN LET SPEED=SPEED-1
```

When player collects 3rd gold piece, SPEED decreases from 3 to 2. Lower PAUSE value = faster gameplay. Creates progression—easy start, challenging finish.

Could extend to:
- Add more enemies at certain scores
- Increase enemy speed independently
- Remove walls to make chasing easier
- Add time pressure

## Lives System Details

Starting with 3 lives:
1. First collision: Drop to 2 lives, reset positions, brief pause
2. Second collision: Drop to 1 life, reset positions, brief pause
3. Third collision: Drop to 0 lives, trigger game over

Gives player multiple chances to learn enemy patterns and develop strategies.

## Professional Game Structure

This game demonstrates professional structure:

**Three distinct phases:**
1. **Title/Setup**: Introduce game, set expectations
2. **Gameplay**: Main loop with all mechanics
3. **Conclusion**: Victory or defeat with appropriate feedback

**Clean subroutine organization:**
- Each system has dedicated subroutine
- Subroutines grouped logically (1000s, 2000s, etc.)
- Easy to modify individual systems without affecting others

**Complete feedback loop:**
- Visual (characters moving, score updating)
- Audio (beeps for actions)
- Textual (messages explaining outcomes)

## Notes

- This game represents mastery of Sinclair BASIC fundamentals
- Uses only character-based graphics (no UDGs yet)
- Simple AI creates challenging gameplay
- Complete game structure ready for expansion
- All Tier 1 concepts integrated seamlessly
- Professional presentation from title to game over
- Demonstrates that powerful games don't require assembly language

## What You've Mastered

By completing this lesson, you've mastered:
- Complete game architecture (title/play/end)
- Multiple system integration (movement/collection/chase/scoring)
- Lives and difficulty systems
- Professional presentation
- Subroutine organization
- State management
- Sound design
- Visual feedback
- Game pacing

**You can now create complete, professional ZX Spectrum games using BASIC.**

## Next Steps: Tier 2

Tier 2 introduces advanced techniques:
- User-Defined Graphics (UDGs) for custom sprites
- Advanced AI patterns
- Multi-screen games
- Level progression systems
- Data-driven level design
- Advanced sound techniques
- Assembly language integration

But first: Master these Tier 1 fundamentals. Experiment with the code. Create variations. Make this game yours. The skills you've learnt here form the foundation for everything that follows.
