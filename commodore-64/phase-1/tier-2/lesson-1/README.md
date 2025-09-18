# Lesson 33: Decision Making with Branches

Learn how your programs can make decisions using conditional branches - the foundation of all game logic and AI behavior.

## System Information
- **Platform**: Commodore 64
- **Phase**: 1 (Assembly Foundations)
- **Tier**: 2 (Programming Logic & Control)
- **Lesson**: 1 (Global #33)

## Files Included
- `main.asm` - Complete working program demonstrating conditional branching with AI guard behavior

## Building the Code

### Using ACME Assembler
```bash
acme -o program.prg main.asm
```

### Using Docker Environment
```bash
docker run --rm -v $(pwd):/workspace code198x/acme acme -o program.prg main.asm
```

## Running the Program

### VICE Emulator (x64sc)
```bash
x64sc program.prg
```

### Controls
- **Joystick Port 2** or **Arrow Keys**: Move the player (blue character)
- The red guard will patrol and chase you when nearby!

## What This Demonstrates

This lesson showcases:
- Conditional branching with BEQ, BNE, BCS, BCC
- Multi-state AI behavior (patrol, chase, return)
- Distance calculations for proximity detection
- Joystick input handling with decision trees
- Border color feedback for state visualization

## Key Concepts

### Branching Instructions
- **BEQ** (Branch if Equal): Jump when zero flag is set
- **BNE** (Branch if Not Equal): Jump when zero flag is clear
- **BCS** (Branch if Carry Set): Jump when carry flag is set
- **BCC** (Branch if Carry Clear): Jump when carry flag is clear

### AI States
1. **Patrol State** (Border: Black) - Guard moves back and forth
2. **Chase State** (Border: Red) - Guard pursues the player
3. **Return State** (Border: Cyan) - Guard returns to patrol route

## Learning Goals

After this lesson, you'll understand:
- How processors make decisions based on flags
- Building complex behavior from simple conditions
- Creating responsive game AI
- Efficient state management in assembly

## Download

📥 [View Full Lesson](https://code198x.stevehill.xyz/lessons/commodore-64/phase-1/tier-2/33)

## License

Educational use encouraged! Part of the Code Like It's 198x curriculum.