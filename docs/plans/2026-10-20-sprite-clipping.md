# Clip software objects at the viewport

Merge and verify the approved lifecycle tranche (samples117/site853), then extend its rendering progression without changing existing interfaces or evidence.

1. Add signed-coordinate axis clipping implementations in Spectrum Z80, BBC 6502 and Amiga 68000 under each `patterns/assembly/rendering/clipped-sprites/`. Return destination, skipped source units and visible extent; handle empty/off-screen rectangles before calculating screen addresses. Use explicit contracts and preserve aligned source formats.
2. Add bounded masked drawing adapters and complete original callers. Spectrum/BBC use horizontal byte units; Amiga uses words and explicit source/screen row strides. Demonstrate cropped edges/corners and a visible interior object. Explain how lifecycle buffers use the old clipped rectangle; retain hardware sprite differences rather than forcing this software method onto C64/NES.
3. Verify guest outputs against independent interval and bitmap/bitplane oracles, including zero extents, negative positions, fully invisible objects, source cropping, right/bottom boundaries, source preservation and neighbouring data. Require deliberate clipping/source-offset failures to be rejected. Retain source/tool/configuration/capture identity; firmware stays local. Add fresh CI where the existing tool path supports it.
4. Add the shared clipping article and three machine implementations with actual reusable code and complete callers, source/evidence links and captures. Update only related lifecycle/family links and the coverage inventory. Build and inspect the production site on desktop/phone; run relevant content and browser checks.
5. Push verified commits, prepare draft PRs and a review pack, update docs117, then remove task worktrees, fixtures, downloaded tools and servers. The new clipping tranche remains unpublished for review.

Files: the three `*/patterns/assembly/rendering/clipped-sprites/{clip.inc,draw.inc,demo.asm,Makefile,README.md}` directories; `scripts/verify-sprite-clipping.py`, retained evidence guard/tests and workflow wiring; `docs/sprite-clipping/verification/`; website `cross-platform/rendering/clipping.mdx` plus three `assembly/rendering/clipped-sprites.mdx` entries and related links. No dependencies, schema changes or shared UI changes.

Temporary work: /tmp/sprite-clipping-{samples,website,tools,evidence}; chat work/sprite-clipping and outputs/sprite-clipping. Existing primary checkouts and unrelated changes are preserved.
