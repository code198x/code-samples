# ZX Spectrum Development

This folder contains source code, build scripts, and tools for developing software for the ZX Spectrum using Z80 assembly.

## 📁 Structure

```
zx-spectrum/
├── src/         # Z80 assembly source files
│   └── hello.asm
├── Makefile     # Build targets for .tap and .bin
├── build/       # (Optional) Output folder for artifacts
└── README.md    # This file
```

## 🛠 Tools Used

- **[pasmo](https://pasmo.speccy.org/)** – Generates `.tap` files from `.asm` source
- **[z80asm](https://manpages.debian.org/testing/z80asm/z80asm.1.en.html)** – Produces raw binary `.bin` files
- **[SjASMPlus](https://github.com/z00m128/sjasmplus)** – Assembles Z80 source and generates `.tap` and `.bin` files
- **[Fuse Emulator](http://fuse-emulator.sourceforge.net/)** – Used for running and debugging builds

## ⚙️ Build Instructions

Make sure you have `sjasmplus` installed:

```bash
# Download and install the latest SjASMPlus release (Linux x64)
curl -s https://api.github.com/repos/z00m128/sjasmplus/releases/latest \
  | grep browser_download_url \
  | grep linux64.tar.gz \
  | cut -d '"' -f 4 \
  | wget -i -
tar -xzf sjasmplus-*-linux64.tar.gz
sudo mv sjasmplus /usr/local/bin/
```

Then, from the `zx-spectrum/` directory:

```bash
make          # Builds hello.tap and hello.bin
make clean    # Removes generated files
```

## 🚀 GitHub Actions

This folder is monitored by a [GitHub Actions workflow](../.github/workflows/zx-build.yml) that automatically builds `.tap` and `.bin` files when changes are pushed to this directory.

Artifacts are uploaded and can be downloaded from the workflow run.

## 🧠 About the Example

The provided `hello.asm` fills the top-left portion of the screen with the ASCII character `'A'`, directly writing to video memory starting at `0x4000`.

This is our first step toward understanding video memory, system routines, and the architecture of the ZX Spectrum.

## 📚 Related Blog Post

You can read the accompanying blog post here: [ZX Spectrum: Getting Started the Right Way](#)

---

More features coming soon: color attributes, keyboard input, custom font rendering, and more.