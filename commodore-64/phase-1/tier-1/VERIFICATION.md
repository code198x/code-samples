# C64 Lesson Verification Flow

This document describes the verification process for ensuring C64 lessons work correctly.

## Verification Requirements

### 1. Code Quality
- ✅ **Compilation**: Code must compile without errors using ACME assembler
- ✅ **Memory Safety**: No unsafe zero page usage (avoid `$f0-$ff`)
- ✅ **Runtime**: No crashes or infinite loops during execution

### 2. Visual Verification
- ✅ **Screenshot Capture**: Must produce meaningful visual output
- ✅ **Emulator Compatibility**: Must work with VICE x64sc emulator
- ✅ **Timing**: Must initialize properly within cycle limits

### 3. Progressive Complexity
- ✅ **Lesson 4**: Sprite-based ship, starfield, collision detection
- ✅ **Lesson 5**: Character-based graphics, scoring system

## Verification Commands

### Standard Verification
```bash
# Build and test a lesson
acme -f cbm -o cosmic-harvester-XX.prg cosmic-harvester-XX.asm
x64sc -autostart cosmic-harvester-XX.prg -autostartprgmode 1 -warp -limitcycles 10000000 -exitscreenshot lesson-XX-verified.png
```

### Key Parameters
- **`-limitcycles 10000000`**: Gives enough time for proper initialization
- **`-warp`**: Speeds up execution for testing
- **`-autostartprgmode 1`**: Ensures proper program loading
- **`-exitscreenshot`**: Captures final state for verification

## Screenshot Integration

Screenshots are automatically captured and stored in:
- `screenshots/lesson-XX-verified.png`: Verification screenshots
- Individual lesson directories: Working examples

## Verification Results

### ✅ Working Lessons
- **Lesson 4**: Shows black background with white stars and cyan ship sprite
- **Lesson 5**: Shows blue background with score display and character graphics

### Common Issues Fixed
1. **Zero Page Conflicts**: Moved variables from `$f0-$ff` to `$20-$27`
2. **Timing Issues**: Increased cycle limits from 1M to 10M
3. **Graphics Architecture**: Maintained sprite-based system instead of downgrading

## Integration with Website

Screenshots are automatically integrated into lesson pages using:
1. Capture during verification process
2. Copy to website assets directory
3. Reference in lesson markdown content

## Automation

The verification process is automated via:
- `verify-lessons.sh`: Batch verification script
- `Makefile`: Build automation (future)
- CI/CD integration: GitHub Actions (future)

## Best Practices

1. **Always verify before publishing**: Run verification for every lesson change
2. **Keep screenshots current**: Re-capture when code changes
3. **Document failures**: Record and fix any verification issues
4. **Test emulator compatibility**: Ensure works across different VICE versions

## Troubleshooting

### Black Screen Issues
- **Cause**: Screenshot taken too early in initialization
- **Solution**: Increase cycle limit or add startup delays

### Crash Issues  
- **Cause**: Memory conflicts or invalid operations
- **Solution**: Check zero page usage and memory safety

### Missing Visual Elements
- **Cause**: Incomplete initialization or wrong graphics mode
- **Solution**: Verify sprite setup and screen clearing routines