# Gloaming — tape loading screen

The SCREEN$ that loads ahead of the game on a cassette: the walled
square at dusk, built from Gloaming's own art.

## Files

| File | What |
|------|------|
| `compose.py` | The generator — composes the screen cell-by-cell from the game's glyphs, textures and palette. Source of truth. |
| `loading-screen.png` | Its output: a 256×192 source image, already on the Spectrum's 2-colour-per-cell grid. |
| `gloaming.scr` | The 6912-byte SCREEN$, converted from the PNG by `build198x image`. The block the tape master embeds. |

## Why compose, not generate

A Spectrum SCREEN$ is 32×24 cells of 8×8 pixels, **two colours per
cell** (one INK, one PAPER, one BRIGHT). Photographic or model-generated
art assumes per-pixel colour freedom and clashes hard when forced onto
that grid. Composing to the grid from the start — here, from the game's
actual lamplighter/lantern/wisp sprites, cobble/brick/mist textures and
exact dusk attributes — is clean by construction. The proof is in the
conversion: `mean_error 0.0`, zero cells over threshold, and the tool's
own diagnosis, *"input appears already constrained."*

## Regenerate

```
python3 compose.py
build198x image loading-screen.png \
    --machine sinclair-zx-spectrum --format scr --dither none -o gloaming.scr
```

`build198x` lives in the Build198x sibling; `--dither none` is correct
because the input is already constrained (dithering a clean image only
adds noise). The `.scr` is committed so the tape artefact has its input
without a Build198x checkout, but it is fully derived from the PNG.
