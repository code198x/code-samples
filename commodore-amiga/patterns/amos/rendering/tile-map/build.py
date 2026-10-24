"""Combine maintained ASCII modules; import into original AMOS, not a token save."""

import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
F = Path(__file__).parent
spec = importlib.util.spec_from_file_location(
    "cases", ROOT / "cross-platform/patterns/rendering/tile-map/managed-cases.py"
)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
VARIANTS = ("small", "working", "custom", "wrong", "repaired", "boundaries")


def program(name):
    if name not in VARIANTS:
        raise ValueError(name)
    helper = (F / "routines.amos").read_text()
    if name == "small":
        return (F / "caller.amos").read_text() + helper
    if name == "wrong":
        helper = helper.replace("PL_TM_Y*PL_TM_W+PL_TM_X", "PL_TM_Y*PL_TM_H+PL_TM_X")
    cases = C.cases()
    N = len(cases)
    size = N * 48 + 2
    caller = f"""Hide : Palette $000,$FFF : Paper 0 : Pen 1 : Cls 0
Dim PL_TM_MAP(35),PL_TM_PROPS(3)
For PL_I=0 To 34 : PL_TM_MAP(PL_I)=PL_I mod 4 : Next PL_I
PL_TM_MAP(35)=99
PL_TM_MAX=3 : PL_TM_PC=4
PL_TM_PROPS(0)=0 : PL_TM_PROPS(1)=1 : PL_TM_PROPS(2)={1 if name == "custom" else 2} : PL_TM_PROPS(3)=3
Reserve As Work 1,{size}
PL_MAILBOX=Start(1)
Locate 0,3 : Print "Bank: ";PL_MAILBOX
Locate 0,4 : Print "Size: ";Length(1)
For PL_CASE=0 To {N - 1}
   Read PL_OP,PL_TM_X,PL_TM_Y,PL_TM_TILE,PL_TM_WX,PL_TM_WY,PL_TM_W,PL_TM_H,PL_TM_CAP
   If PL_OP=0 : Gosub PL_TM_GET : End If
   If PL_OP=1 : Gosub PL_TM_SET : End If
   If PL_OP=2 : Gosub PL_TM_PROPERTY : End If
   If PL_OP=3 : Gosub PL_TM_PIXEL8 : End If
   PL_AT=PL_MAILBOX+PL_CASE*48
   Doke PL_AT,PL_TM_VALID : Doke PL_AT+2,PL_TM_TILE : Doke PL_AT+4,PL_TM_PROP
   Doke PL_AT+6,PL_TM_X : Doke PL_AT+8,PL_TM_Y
   For PL_I=0 To 35 : Poke PL_AT+10+PL_I,PL_TM_MAP(PL_I) : Next PL_I
   Doke PL_AT+46,$A55A
Next PL_CASE
Doke PL_MAILBOX+{N * 48},$CAFE
Locate 0,0 : Print "Map queries complete"
Locate 0,1 : Print "Count:";{N}
Locate 0,2 : Print "Exit: ";PL_TM_PROPS(2)
Repeat : Wait Vbl : Until Inkey$="q"
Erase 1 : Show
End
"""
    data = "".join(
        "Data "
        + ",".join(
            str(c[k]) for k in ("op", "x", "y", "tile", "wx", "wy", "w", "h", "cap")
        )
        + "\n"
        for c in cases
    )
    return caller + data + helper


if __name__ == "__main__":
    B = F / "build"
    B.mkdir(exist_ok=True)
    (B / "demo.asc").write_text(
        (F / "caller.amos").read_text() + (F / "routines.amos").read_text()
    )
    for n in VARIANTS:
        (B / (n + ".asc")).write_text(program(n))
