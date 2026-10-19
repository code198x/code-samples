# Game loop on the Acorn Electron

This deliberately reuses the BBC Micro MOS-facing frame.inc, demo.asm and generated loader.bas under `bbc-micro/patterns/assembly/framework/game-loop`. No copied hardware driver is hidden here. `make` delegates to that source folder; its build output remains there. Enter that loader on the Electron and RUN it.

MODE 6, the load address and MOS entry points are shared by this bounded example. The Electron has its own pinned OS/BASIC firmware and execution record. Its display/memory behaviour and workload cost are not inferred from the BBC run. Hold Space to add work; release to recover. Reset to leave.

Run the maintained recipe with --only electron or --include-electron. The record checks executable installation (excluding only declared mutable state), normal/slow/recovered updates and a rejected unpaced control. This does not qualify every MOS call, display mode or peripheral.
