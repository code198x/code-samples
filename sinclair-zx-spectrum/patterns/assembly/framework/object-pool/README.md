# Reusable object slots on Spectrum

Call pool_acquire: carry clear / A = slot means success; carry set / A = capacity means full. pool_release takes A = index, and returns carry clear on release or carry set for invalid/already free. It does not promise to preserve A. AF, BC and HL change; DE, IX and IY survive. No port, interrupt or hidden scratch ownership. A direct call uses a two-byte return address. The optional ageing pass also saves a two-byte loop counter while making a nested release call.

The standalone 48K PAL caller is entered by the ROM tape loader and BASIC USR. It disables interrupts, owns the bitmap, attributes and border port, and uses ROM glyphs for its small diagnostic row. It stays running; it does not restore a BASIC session. Its code starts at $8000 and its private flags, payload, packet and output variables follow the code. The reusable routines touch none of those video or port resources.

Include pool.inc once after reserving pool_flags[N], N=1..255; pool_init clears only flags. Only capacities4 and8 are qualified here. Payload is caller-owned; release does not clear it. Initialise payload after acquisition before any reader. No spawning during the optional age pass. Live lifetime1..255. Discard stale references when freeing; no generational handles or hardware sprite allocation.

Measured helper 56 code bytes +N flags; optional age 39 code bytes +N lifetime bytes. Init/age scan N; acquire scans to the first free or allN; release is bounded. These are operation/storage counts, not hardware timing.

Demo preview00 01 02 FF 01 01 AA 00; custom capacity4 changes AA to0A. Wrong omits release and changes reacquired01 toFF; repaired executable equals demo. Build with make ASM198X=/path/to/asm198x. Native configuration/evidence is in verification; scripts/verify-pools-and-states.py --topic object-pool --system sinclair-zx-spectrum supplies the native producer, and scripts/check-pools-and-states.py plus test_pools_and_states.py validate/corrupt evidence. No firmware-bearing snapshots are retained publicly.
