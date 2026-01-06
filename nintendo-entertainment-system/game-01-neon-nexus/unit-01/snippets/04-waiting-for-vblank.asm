; Wait for first vblank
    bit PPUSTATUS
@vblank1:
    bit PPUSTATUS
    bpl @vblank1
