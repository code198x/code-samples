# Screenshot and Video Capture Setup - Code198x

## Overview
This document describes the complete screenshot and video capture setup for all systems in the Code198x project. Each system now has verification scripts and video recording capabilities.

## System Coverage

### ✅ Commodore 64 (Fully Operational)
**Location**: `code-samples/commodore-64/phase-1/tier-1/`
**Status**: Production ready with automated capture

**Tools**:
- `verify-lessons.sh` - Automated build, test, and screenshot capture
- `record-lesson-video.sh` - Automated video recording with multiple methods
- VICE x64sc emulator with command-line screenshot support

**Capabilities**:
- ✅ Automated compilation verification
- ✅ Automated screenshot capture via VICE --exitscreenshot
- ✅ Automated video recording via screencapture
- ✅ Multiple video recording methods (screencapture, ffmpeg, automated input)
- ✅ Complete documentation and troubleshooting

**Sample Output**:
- Screenshots: 5 lessons verified (1.1-1.4 KB PNG files)
- Videos: lesson-04-demo.mp4 (6.4MB, 5-second demonstration)

### ✅ ZX Spectrum (Ready for Manual Operation)
**Location**: `code-samples/zx-spectrum/phase-1/tier-1/`
**Status**: Scripts created, requires manual emulator operation

**Tools**:
- `verify-lessons.sh` - Build verification and TAP file creation
- `record-lesson-video.sh` - Video recording setup and instructions
- FUSE emulator (requires manual operation)

**Capabilities**:
- ✅ Automated compilation verification
- ✅ TAP file generation via sjasmplus
- ✅ Manual screenshot capture instructions
- ✅ Manual video recording instructions
- ✅ Detailed step-by-step process documentation

**Manual Process**:
1. Run `./verify-lessons.sh` to build TAP files
2. Run `./record-lesson-video.sh` to get recording instructions
3. Launch FUSE manually: `fuse --machine 48 --tape quantum-shatter-04.tap`
4. Record with: `screencapture -v -V 10 lesson-04-demo.mp4`
5. In FUSE: `LOAD ""` then play the game

### ✅ Nintendo Entertainment System (Ready for Manual Operation)
**Location**: `code-samples/nintendo-entertainment-system/phase-1/tier-1/`
**Status**: Scripts created, requires manual emulator operation

**Tools**:
- `verify-lessons.sh` - Build verification and ROM creation
- FCEUX emulator with potential Lua scripting
- ca65/ld65 toolchain for ROM generation

**Capabilities**:
- ✅ Automated compilation verification
- ✅ NES ROM file generation
- ✅ Emulator detection and path finding
- ✅ Manual screenshot capture framework
- ✅ Lua scripting hooks for automated testing

**Manual Process**:
1. Run `./verify-lessons.sh` to build NES ROMs
2. Launch FCEUX: `fceux underground-assault-04.nes`
3. Record with: `screencapture -v -V 10 lesson-04-demo.mp4`
4. Play the game while recording

### ✅ Commodore Amiga (Ready for Manual Operation)
**Location**: `code-samples/commodore-amiga/phase-1/tier-1/`
**Status**: Scripts created, requires manual emulator operation

**Tools**:
- `verify-lessons.sh` - Build verification and executable creation
- vasm (vasmm68k_mot) assembler
- ADF creation tools (xdftool when available)

**Capabilities**:
- ✅ Automated compilation verification
- ✅ Amiga executable generation
- ✅ ADF disk image creation support
- ✅ FS-UAE emulator detection
- ✅ Manual testing process documentation

**Manual Process**:
1. Run `./verify-lessons.sh` to build executables
2. Launch FS-UAE with hard drive mount
3. Record with: `screencapture -v -V 10 lesson-04-demo.mp4`
4. Run executable in Amiga environment

## Technical Implementation

### Screenshot Capture Methods

#### Method 1: Emulator Built-in (C64 Only)
```bash
x64sc -autostart program.prg -exitscreenshot output.png -limitcycles 10000000
```
- ✅ Automated and reliable
- ✅ Perfect timing control
- ✅ High quality output
- ❌ Only works with VICE

#### Method 2: Screen Capture (All Systems)
```bash
screencapture -x -t png screenshot.png
```
- ✅ Works with any emulator
- ✅ Captures actual screen output
- ❌ Requires manual timing
- ❌ May include desktop elements

#### Method 3: Manual Process (All Systems)
1. Launch emulator
2. Load ROM/TAP/executable
3. Position emulator window
4. Take screenshot manually or via script
5. Save with consistent naming

### Video Recording Methods

#### Method 1: macOS screencapture (Primary)
```bash
screencapture -v -V 10 output.mp4
```
- ✅ Native macOS tool
- ✅ Good quality output
- ✅ Easy to use
- ❌ Captures full screen

#### Method 2: FFmpeg (Alternative)
```bash
ffmpeg -f avfoundation -i "2" -t 10 -r 30 output.mp4
```
- ✅ High quality output
- ✅ Configurable settings
- ✅ Cross-platform
- ❌ Requires FFmpeg installation

#### Method 3: Automated Input (C64 Only)
```bash
# AppleScript for automated keypresses during recording
osascript automation.scpt &
screencapture -v -V 10 output.mp4
```
- ✅ Demonstrates actual gameplay
- ✅ Consistent input across recordings
- ❌ Complex to set up
- ❌ System-specific

## File Organization

### Directory Structure
```
code-samples/
├── commodore-64/phase-1/tier-1/
│   ├── verify-lessons.sh ✅
│   ├── record-lesson-video.sh ✅
│   ├── screenshots/ ✅
│   └── videos/ ✅
├── zx-spectrum/phase-1/tier-1/
│   ├── verify-lessons.sh ✅
│   ├── record-lesson-video.sh ✅
│   └── screenshots/ (pending manual capture)
├── nintendo-entertainment-system/phase-1/tier-1/
│   ├── verify-lessons.sh ✅
│   └── screenshots/ (pending manual capture)
└── commodore-amiga/phase-1/tier-1/
    ├── verify-lessons.sh ✅
    └── screenshots/ (pending manual capture)
```

### Naming Conventions
- **Screenshots**: `lesson-XX-verified.png` (automated) or `lesson-XX-manual.png`
- **Videos**: `lesson-XX-demo.mp4` (5-10 seconds typical)
- **Build artifacts**: System-specific (`.prg`, `.tap`, `.nes`, executable)

## Quality Standards

### Screenshot Requirements
- **Resolution**: Native system resolution preferred
- **Format**: PNG for lossless quality
- **Content**: Show actual game output, not loading screens
- **Timing**: Capture after full initialization
- **Size**: Typically 1-2 KB for retro graphics

### Video Requirements
- **Duration**: 5-10 seconds typical, up to 30 seconds for complex demos
- **Format**: MP4 (H.264)
- **Frame Rate**: 30 FPS recommended
- **Resolution**: 720p minimum, native system aspect ratio
- **Content**: Show actual gameplay, not just static screens

## Automation Status

### Fully Automated
- ✅ **C64**: Complete build → test → screenshot → video pipeline
- ✅ **Build verification**: All systems automatically verify compilation

### Semi-Automated
- ✅ **ZX Spectrum**: Build automation + manual recording instructions
- ✅ **NES**: Build automation + manual recording instructions  
- ✅ **Amiga**: Build automation + manual recording instructions

### Manual Steps Required
1. **Launch emulators** (except C64 VICE)
2. **Load games** in emulator
3. **Position windows** for recording
4. **Start recording** and play games
5. **Stop recording** and save files

## Next Steps

### High Priority
1. **Manual screenshot capture** for Spectrum, NES, and Amiga lessons
2. **Video recording** for one lesson per system as demonstration
3. **Emulator automation** investigation for non-C64 systems

### Medium Priority
1. **FS-UAE automation** for Amiga (headless mode research)
2. **FCEUX Lua scripting** for NES automation
3. **FUSE command-line options** for ZX Spectrum automation

### Low Priority
1. **Cross-platform compatibility** (Linux, Windows)
2. **CI/CD integration** for automated verification
3. **Web-based emulation** for browser demonstrations

## Troubleshooting

### Common Issues
1. **"Emulator not found"** - Check PATH and installation
2. **"Screenshot failed"** - Verify emulator supports headless mode
3. **"Build failed"** - Check assembler installation and file paths
4. **"Video too large"** - Adjust recording duration and quality settings

### System-Specific Issues
- **C64**: Increase cycle limits if screenshot is black
- **ZX Spectrum**: Ensure TAP file has proper SAVETAP directive
- **NES**: Verify nes.cfg linker script is present
- **Amiga**: Check vasm assembler flags and output format

## Usage Examples

### Quick Verification (All Systems)
```bash
cd code-samples/commodore-64/phase-1/tier-1
./verify-lessons.sh

cd code-samples/zx-spectrum/phase-1/tier-1  
./verify-lessons.sh

cd code-samples/nintendo-entertainment-system/phase-1/tier-1
./verify-lessons.sh

cd code-samples/commodore-amiga/phase-1/tier-1
./verify-lessons.sh
```

### Video Recording (C64 Automated)
```bash
cd code-samples/commodore-64/phase-1/tier-1
./record-lesson-video.sh 4 10  # Lesson 4, 10 seconds
```

### Video Recording (Other Systems)
```bash
cd code-samples/zx-spectrum/phase-1/tier-1
./record-lesson-video.sh 4 10  # Get manual instructions
```

## Conclusion

The Code198x project now has comprehensive screenshot and video capture capabilities:

- **1 fully automated system** (C64) with complete pipeline
- **3 semi-automated systems** (ZX Spectrum, NES, Amiga) with build verification and manual recording instructions
- **Consistent tooling** across all systems
- **Detailed documentation** for both automated and manual processes
- **Quality standards** ensuring professional educational content

This setup enables the creation of high-quality visual content for the educational platform while maintaining authentic retro gaming development workflows.

---

*Last Updated: July 18, 2024*  
*Status: Production ready for C64, Manual ready for other systems*