#!/bin/bash
# Build all NES lesson samples (017-032)

echo "Building NES lessons 017-032..."

for lesson in {017..032}; do
    dir="lesson-$lesson"
    if [ -d "$dir" ]; then
        echo "Building $dir..."
        cd "$dir"
        
        # Find .asm file
        asm_file=$(ls *.asm 2>/dev/null | head -1)
        
        if [ -n "$asm_file" ]; then
            base="${asm_file%.asm}"
            
            # Assemble
            ca65 "$asm_file" -o "${base}.o" 2>&1 | head -20
            
            if [ $? -eq 0 ]; then
                # Link (use lesson-001's config)
                ld65 "${base}.o" -C ../lesson-001/nes.cfg -o "${base}.nes" 2>&1 | head -20
                
                if [ $? -eq 0 ]; then
                    echo "  ✓ ${base}.nes created"
                else
                    echo "  ✗ Linking failed"
                fi
            else
                echo "  ✗ Assembly failed"
            fi
        else
            echo "  ⚠ No .asm file found"
        fi
        
        cd ..
    fi
done

echo "Done!"
