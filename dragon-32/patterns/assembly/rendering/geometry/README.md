# dragon integer geometry

Start with `demo.asm`: it sets up the stated native mode and directly calls
`geo_ellipse` before entering a verification mailbox. The mailbox is optional;
your game calls the five reusable geometry entries directly.

See [the shared calling contract](../../../../../cross-platform/patterns/rendering/geometry/README.md)
for inclusion, workspace layout, clipping, endpoint ownership, range limits,
operation semantics, resources, measured costs and primary references.

From repository root:

```sh
make -C dragon-32/patterns/assembly/rendering/geometry ASM198X=/path/to/asm198x
python3 scripts/verify-geometry.py --system dragon --native /path/to/native-binaries --assembler /path/to/asm198x
python3 scripts/check-geometry.py
```

`build/fixture.bin` contains only original reset code. `verification/` retains
complete per-call memory, selected native frames, source/tool bindings and
completed faulty-build observations. `build/verification/` is the destination
for a fresh run; reviewed observations are never replaced automatically.
