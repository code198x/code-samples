"""Combine typed Blitz source for ASCII insertion into original Ted."""

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
    helper = (F / "routines.bb2").read_text()
    if name == "small":
        return (F / "caller.bb2").read_text() + helper
    if name == "wrong":
        helper = helper.replace(
            "PL_TM_Y.l*PL_TM_W.l+PL_TM_X.l", "PL_TM_Y.l*PL_TM_H.l+PL_TM_X.l"
        )
    cases = C.cases()
    N = len(cases)
    size = N * 168 + 8
    caller = f"""WbToScreen 0
Window 0,0,20,420,180,$1000,"Checked map queries",1,0
Dim PL_TM_MAP.l(35),PL_TM_PROPS.l(3)
For PL_I.l=0 To 34 : PL_TM_MAP.l(PL_I.l)=PL_I.l MOD 4 : Next
PL_TM_MAP.l(35)=99
PL_TM_MAX.l=3 : PL_TM_PC.l=4
PL_TM_PROPS.l(0)=0 : PL_TM_PROPS.l(1)=1 : PL_TM_PROPS.l(2)={1 if name == "custom" else 2} : PL_TM_PROPS.l(3)=3
InitBank 0,{size},1 : PL_box.l=Bank(0)
For PL_case.l=0 To {N - 1}
  Read PL_op.l,PL_TM_X.l,PL_TM_Y.l,PL_TM_TILE.l,PL_TM_WX.l,PL_TM_WY.l,PL_TM_W.l,PL_TM_H.l,PL_TM_CAP.l
  If PL_op.l=0 : Gosub PL_TM_GET : EndIf
  If PL_op.l=1 : Gosub PL_TM_SET : EndIf
  If PL_op.l=2 : Gosub PL_TM_PROPERTY : EndIf
  If PL_op.l=3 : Gosub PL_TM_PIXEL8 : EndIf
  PL_at.l=PL_box.l+PL_case.l*168
  Poke.l PL_at.l,PL_TM_VALID.l : Poke.l PL_at.l+4,PL_TM_TILE.l : Poke.l PL_at.l+8,PL_TM_PROP.l
  Poke.l PL_at.l+12,PL_TM_X.l : Poke.l PL_at.l+16,PL_TM_Y.l
  For PL_i.l=0 To 35 : Poke.l PL_at.l+20+PL_i.l*4,PL_TM_MAP.l(PL_i.l) : Next
  Poke.l PL_at.l+164,$A55A
Next
Poke.l PL_box.l+{N * 168},$1A2B3C4D : Poke.l PL_box.l+{N * 168 + 4},239
WLocate 8,20 : Print "Count: ",{N}
WLocate 8,40 : Print "Exit: ",PL_TM_PROPS.l(2)
WLocate 8,60 : Print "Bank: ",PL_box.l
WLocate 8,80 : Print "Size: ",BankSize(0)
WLocate 8,100 : Print "0123456789"
Repeat : VWait : Until Inkey$="q"
DefaultInput : DefaultOutput
Free Window 0 : FreeBank 0
End
"""
    data = "".join(
        "Data.l "
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
    (B / "demo.asc").write_text(program("small"))
    for n in VARIANTS:
        (B / (n + ".asc")).write_text(program(n))
