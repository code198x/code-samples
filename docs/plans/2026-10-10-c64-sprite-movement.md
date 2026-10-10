# Execute and repair Sprite Movement with Bounds

Approved scope: complete the C64 joystick-driven movement example and verify
clamping, diagonals, ninth-X-bit transitions, opposite directions and shared
register preservation in Emu198x and VICE on PAL and NTSC.

Design: retain the page's two-pixel-per-update speed and inclusive bounds
X=24..320, Y=50..229 for a normal 24x21 sprite in a 40-column/25-row display.
Sample port 2 once per update. Opposite directions cancel on their own axis;
diagonal movement applies both axes (not normalised). Clamp the candidate
position to the edge. Separate the small joystick reader from the movement
routine so injected-input maths tests do not pretend to exercise the port.
The standalone caller reuses the verified Hardware Sprites setup/shape,
updates once per frame below the displayed area and owns the CIA/interrupt
configuration. No new architecture, dependencies or emulator changes.

1. Preserve the original MDX listing and its revision/hash under the sample's
   `verification/` folder. Assemble it in a bounded fixture, reproduce
   Y=51/up staying at 51 and lower-edge failures, and retain actual observations.
2. Add `movement.inc`, `demo.asm`, `Makefile` and `README.md` in
   `commodore-64/patterns/assembly/physics/sprite-movement-bounds/`.
   Extend its verifier with a reference calculation independent of the
   assembly: clamp(start + signed direction * 2). Test all 16 direction
   masks over a boundary matrix, including 255/256 and odd/even positions.
   Assert RAM state, VIC coordinates, high-bit preservation and frame progress.
3. Drive real emulator joystick inputs through the standalone program,
   including held/released controls and diagonals; verify PAL/NTSC visible
   pixels and register observations in both engines. Compare Asm198x/ACME
   binaries and prove regressions fail with a deliberately broken clamp.
4. Commit the verified sample. Update the website's
   `sprite-movement-bounds.mdx` to use CodeFromFile and a pinned evidence link.
   Explain inclusive bounds, regional frame speed and ownership; remove
   unsupported costs and the unverified lesson attribution. Build, check
   rendered desktop/mobile pages and source/evidence consistency. Commit
   and merge when checks pass, preserving unrelated work.

Baseline: samples `daacb295441b54fc239b63c6229347308ec18dd2`, website
`a445b33aea26d5f08df4d314b0911b3f0226f7b9`. No changes to the adjacent
Joystick Reading or Raster Splits patterns are included.
