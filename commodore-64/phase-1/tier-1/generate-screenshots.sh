#!/bin/bash

# Generate screenshots for all lessons
for lesson in lesson-002 lesson-003 lesson-004 lesson-005 lesson-006 lesson-007 lesson-008; do
    echo "Generating screenshot for $lesson..."
    cd $lesson
    
    # Clean and build
    make clean > /dev/null 2>&1
    make > /dev/null 2>&1
    
    # Find the .prg file
    prg_file=$(ls build/*.prg 2>/dev/null | head -1)
    
    if [ -f "$prg_file" ]; then
        # Run emulator briefly and capture screenshot
        timeout 5 x64sc "$prg_file" > /dev/null 2>&1 &
        sleep 2
        killall x64sc > /dev/null 2>&1
        
        # Find and rename the screenshot
        screenshot=$(ls vice-screen-*.png 2>/dev/null | head -1)
        if [ -f "$screenshot" ]; then
            mv "$screenshot" "${lesson}-screenshot.png"
            echo "Screenshot saved as ${lesson}-screenshot.png"
        else
            echo "No screenshot generated for $lesson"
        fi
    else
        echo "No .prg file found for $lesson"
    fi
    
    cd ..
done

echo "Screenshot generation complete!"