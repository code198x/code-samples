#!/bin/bash

# Video recording script for ZX Spectrum lessons
# This script records gameplay videos using screen capture

set -e

echo "🎬 ZX Spectrum Lesson Video Recording Script"
echo "============================================"

# Configuration
LESSON_NUM=${1:-4}
DURATION=${2:-10}  # Recording duration in seconds
OUTPUT_DIR="videos"
LESSON_DIR="lesson-$(printf "%03d" $LESSON_NUM)"
ASM_FILE="quantum-shatter-$(printf "%02d" $LESSON_NUM).asm"
TAP_FILE="quantum-shatter-$(printf "%02d" $LESSON_NUM).tap"
VIDEO_FILE="$OUTPUT_DIR/lesson-$(printf "%02d" $LESSON_NUM)-demo.mp4"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "📋 Recording Configuration:"
echo "   System: ZX Spectrum"
echo "   Lesson: $LESSON_NUM"
echo "   Duration: ${DURATION}s"
echo "   Output: $VIDEO_FILE"
echo ""

# Check if lesson exists
if [ ! -d "$LESSON_DIR" ]; then
    echo "❌ Lesson directory not found: $LESSON_DIR"
    exit 1
fi

# Build the lesson
echo "🔨 Building lesson..."
cd "$LESSON_DIR"

if [ ! -f "$ASM_FILE" ]; then
    echo "❌ ASM file not found: $ASM_FILE"
    exit 1
fi

if ! make clean && make; then
    echo "❌ Build failed"
    exit 1
fi

if [ ! -f "$TAP_FILE" ]; then
    echo "❌ TAP file not created: $TAP_FILE"
    exit 1
fi

echo "✅ Build successful"

# Method 1: Automated screen recording with FUSE
echo "🎯 Starting automated video recording..."

record_with_screencapture() {
    echo "📹 Method 1: Using screencapture (macOS native)"
    
    # Note: FUSE may not work headlessly, but document the process
    echo "📱 ZX Spectrum TAP file ready: $TAP_FILE"
    echo "⚠️  FUSE emulator requires manual launch for recording"
    
    # For demonstration, create a placeholder
    echo "🎬 To record manually:"
    echo "   1. Launch: fuse --machine 48 --tape $TAP_FILE"
    echo "   2. Load tape: LOAD \"\" (in emulator)"
    echo "   3. Start recording: screencapture -v -V $DURATION ../$VIDEO_FILE"
    echo "   4. Play the game for $DURATION seconds"
    
    # Create a demonstration command file
    cat > "../record-manual.sh" << EOF
#!/bin/bash
echo "🎮 Manual ZX Spectrum Recording Process"
echo "1. Start FUSE emulator with TAP file"
echo "2. Run this command to record:"
echo "   screencapture -v -V $DURATION '$VIDEO_FILE'"
echo "3. In FUSE, type: LOAD \"\" and press ENTER"
echo "4. The recording will capture $DURATION seconds of gameplay"
EOF
    chmod +x "../record-manual.sh"
    
    echo "✅ Manual recording script created: record-manual.sh"
    echo "📝 TAP file verified and ready for recording"
}

# Method 2: Alternative recording with emulator automation
record_with_automation() {
    echo "📹 Method 2: Automated recording attempt"
    
    # Try to detect if we're in a GUI environment
    if [ -n "$DISPLAY" ] || [ -n "$TERM_PROGRAM" ]; then
        echo "🖥️  GUI environment detected - attempting emulator launch"
        
        # This would be the ideal automated flow:
        # 1. Start FUSE
        # 2. Load TAP file
        # 3. Start recording
        # 4. Send keystrokes to emulator
        # 5. Stop recording
        
        echo "🎯 Automated ZX Spectrum recording not fully implemented yet"
        echo "📋 Would require:"
        echo "   - FUSE command-line automation"
        echo "   - AppleScript for keyboard input"
        echo "   - Synchronized screen recording"
        
    else
        echo "🚫 No GUI environment - cannot run emulator"
    fi
}

# Method 3: Screen recording with manual emulator control
record_with_manual_control() {
    echo "📹 Method 3: Manual control recording"
    
    echo "🎮 Instructions for manual recording:"
    echo ""
    echo "Step 1: Prepare the recording"
    echo "   - Have the TAP file ready: $TAP_FILE"
    echo "   - Position terminal and emulator windows"
    echo ""
    echo "Step 2: Start recording"
    echo "   - Run: screencapture -v -V $DURATION '$VIDEO_FILE'"
    echo "   - Or run: ffmpeg -f avfoundation -i \"2\" -t $DURATION -r 30 '$VIDEO_FILE'"
    echo ""
    echo "Step 3: Run emulator"
    echo "   - Launch: fuse --machine 48 --tape $TAP_FILE"
    echo "   - In emulator: LOAD \"\" then press ENTER"
    echo "   - Play the game!"
    echo ""
    echo "Step 4: Video will be saved to: $VIDEO_FILE"
}

# Choose recording method
echo "🎛️  Available recording methods:"
echo "   1. screencapture (requires manual emulator control)"
echo "   2. automated (not fully implemented)"
echo "   3. manual instructions (detailed process)"
echo ""

# Default to method 1 for now
echo "🎬 Using manual recording method..."
record_with_screencapture

# Return to original directory
cd ..

echo ""
echo "🎉 ZX Spectrum recording setup complete!"
echo ""
echo "📁 Files prepared:"
echo "   ✅ TAP file: $LESSON_DIR/$TAP_FILE"
echo "   ✅ Manual recording script: record-manual.sh"
echo "   📹 Video will be saved to: $VIDEO_FILE"
echo ""
echo "🎯 Next steps:"
echo "   1. Run ./record-manual.sh for detailed instructions"
echo "   2. Or manually launch FUSE and record with screencapture"
echo "   3. TAP file is ready to load in any ZX Spectrum emulator"
echo ""
echo "💡 Alternative emulators to try:"
echo "   - FUSE (native macOS)"
echo "   - ZEsarUX (cross-platform)"
echo "   - Retro Virtual Machine (commercial)"