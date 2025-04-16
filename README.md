# Retro Development Projects

Welcome to my all-in-one repository for retro system development. This repo contains code, tools, and workflows for a range of vintage systems including the ZX Spectrum, Commodore 64, Amiga, and more.

## 🎯 Goals

- Write clean, understandable code targeting classic systems
- Build modern toolchains using cross-compilers and emulators
- Blog and document the journey as part of a long-term retro coding series
- Use GitHub Actions to automate builds for each system

## 🗂 Structure

Each system has its own directory:

```
retro-dev/
├── zx-spectrum/
│   ├── src/         # Z80 assembly source code
│   ├── build/       # Compiled TAP and BIN files
│   ├── Makefile     # Build instructions
│   └── .github/workflows/  # GHA workflow for ZX Spectrum
├── c64/
│   └── ...
├── amiga/
│   └── ...
└── README.md
```

## 🔧 GitHub Actions

Each system includes its own GitHub Actions workflow that:

- Watches for changes to its source and Makefile
- Installs required tools (e.g., `pasmo`, `z80asm`)
- Runs builds and uploads `.tap`, `.bin`, or equivalent artifacts

## 📚 Blog Series

This repo accompanies my blog series on retro game and software development. You can follow along starting with the [introductory post](#) and watch as we bring these classic systems back to life — one byte at a time.

Stay tuned!