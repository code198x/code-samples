# Mapper-0 reset diagnostic

Cold reset produces black and white vertical stripes across the 256×240 image,
a computed 0–255 RAM page at `$0300`, and completion bytes `$5A,$5B` at `$0200`.
The signature is computed after PPU setup; it is not copied from the cartridge.
Source and generated graphics are MIT licensed, like this repository.

This is one explicitly specified NTSC homebrew mapper-0 configuration: 32 KiB
PRG ROM, 8 KiB CHR ROM, legacy iNES 8 KiB PRG RAM, horizontal mirroring, no
battery, trainer or expansion. It is not a claim about every commercial NROM
board. PRG RAM is declared but not exercised. No BIOS is required.

From this directory, with Asm198x 0.0.63:

```sh
asm198x --dialect ca65 -C nes.cfg diagnostic.asm --message-format=json -o diagnostic.nes
emu198x-nes --model nintendo-nes-ntsc --rom diagnostic.nes --no-battery-save
```

For an independent build with ca65/ld65:

```sh
ca65 diagnostic.asm -o diagnostic.o
ld65 -C nes.cfg diagnostic.o -o reference.nes
cmp diagnostic.nes reference.nes
```

The layout places the header at file offset 0, PRG at 16, vectors at 32778
and CHR at 32784. The reset vector is `$8000`; NMI/IRQ point to the harmless
`RTI` at `$80A1`. Completion loops at `$809E`. The output is 40976 bytes.
Rendering and interrupts start disabled; two vblanks precede PPU writes.
Tile 1 supplies alternating low-bitplane pixels; the palette selects black
and white. No input, save state, injected memory or external graphics are used.

The umbrella qualification runner owns bounded automation and evidence:
[198x qualification](https://github.com/stevehill1981/198x/tree/main/ops/qualification).
It checks native layout before reset, observes the CPU reach the reset entry,
and then checks execution, RAM and rendered pixels. FCEUX is an independent
execution consumer; ca65/ld65 is an independent assembly consumer.

This fixture does not qualify PAL/Dendy timing, mapper switching, cartridge
RAM, controllers, audio, expansions or hardware revisions. Those remain in
[the NES programme](https://github.com/stevehill1981/198x/issues/68).
