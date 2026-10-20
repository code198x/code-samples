# Prepare a masked image for every pixel phase

Run `python3 prepare.py sprite.json --system spectrum --output phases.inc`; use bbc or amiga for the other representations. --prefix supplies distinct labels for another sprite, --check rejects stale output without writing. The source is original Code198x art in a strict 16x16 three-state format (. transparent, 0 opaque off, 1 opaque ink). Invalid rows, target systems or assembly prefixes fail before output is written.

Spectrum/BBC: eight phases, 24-bit-wide prepared rows, interleaved KEEP-mask/image bytes and sixteen-bit pointer table. Every row is six bytes, every bank784bytes. Amiga: sixteen phases, 32-bit-wide rows, separate opaque-mask/image planes and 32-bit pointer pairs,2176bytes per bank. Native pointer relocation belongs to the assembler/loader; the generator does not invent runtime addresses.

`verification/verify.py --output results.json` independently reconstructs three-state pixels, checks transparent padding and both mask polarities, rejects corrupted mask/image data, and checks malformed inputs. Generated assembly is committed for direct inclusion; make check-assets verifies it still matches the source and tool. It is original code/art, not extracted game imagery.
