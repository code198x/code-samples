# Game Gear Mode 4: reusable character pictures

Include `glyphs.inc`, reserve P (32 RAM bytes), establish the caller-owned video/interrupt policy, then call the init/install/select/replace entries directly. The complete `demo.asm` shows setup and `example_install`; its mailbox is optional evidence transport.

Read the [complete contract, encoding, costs, boundaries and references](../../../../../cross-platform/patterns/rendering/native-glyphs/README.md) before combining this with another renderer. This is a specific allocation, not an OS-safe universal font routine.

Build with `make ASM=/path/to/asm198x`. Retained `verification/` contains full memory observations, native frames, public state and source/tool hashes. The family checker independently replays all 40 calls per build, including completed wrong-slot and wrong-name controls. Original assets and code are MIT licensed.
