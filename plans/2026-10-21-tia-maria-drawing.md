# TIA and MARIA native drawing — #130

1. Read the manufacturer drawing/timing specifications and existing bar/object probes. Keep TIA CPU emission and MARIA DMA/list ownership separate.
2. Atari 2600: atari-2600/patterns/assembly/rendering/playfield-kernel/{playfield.inc,kernel.inc,demo.asm,Makefile,README.md}. A bounded 20-column half-playfield bitmap, clear/set-cell and a fixed 24-band × 8-line NTSC kernel; explicit repeated/mirrored right half, plus original coarse glyph data. Prepare picture data outside the visible kernel. Fit context, buffer, results and stack in 128-byte RIOT RAM.
3. Atari 7800: atari-7800/patterns/assembly/rendering/maria-objects/{objects.inc,demo.asm,Makefile,README.md}. A bounded direct 160A object-list builder, explicit caller-owned DLL zones/graphics layout and frame-safe list publication. Reuse original cartridge reset route; no BIOS authentication claim.
4. Shared qualification: cross-platform/patterns/rendering/tia-maria/ plus scripts/verify-tia-maria.py, check-tia-maria.py and corruption tests. Independently check native memory and pixels, limits/rejects/guards and completed faulty kernel/list variants. Record CPU scanline schedule or DMA/list workload, code/context/data costs and per-machine limitations.
5. Website: two machine-specific CodeFromFile entries, native captures, include/init/call contracts and reciprocal Maths links. Appropriate source-build/content/browser checks, all sample Makefiles with website tool pin, pinned-source PRs.
6. Update the 30-machine matrix with new review entries and actual evidence, not framebuffer claims. Push and attach review PRs; update #130/#121. Preserve evidence/remote commits, clean owned worktrees/tools/processes before reporting. New work stays unmerged for review.

Selected design follows #130 and the approved recommendation. Hardware research may narrow concrete bounds; record any required correction before implementation. No dependencies or curriculum track are added.
