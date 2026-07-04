#!/usr/bin/env python3
"""Generate the closed-design WIN capture: all six contested coins -> THE KEEP
STANDS. Deterministic: movement is one cell per frame (QAOP), and every room
re-instantiates its Warden with a fresh WARDEN_GATHER (50-frame) frozen window on
entry, so each room's two coins are collected inside that window while its Warden
stands still, with inter-room travel routed down Warden-free columns. draw_room
paints ~18 frames on new_game AND every room entry; the gather only counts after
the draw, so a ~22-frame settle after each transition clears the draw with the
full frozen window still ahead.

Coins (col,row) as authored:
  Hall    (26,6)  (26,20)   Warden col 26, frozen at (26,11)
  Gallery (24,11) (24,20)   Warden col 24, frozen at (24,15)
  Vault   (10,20) (20,20)   Warden row 20, frozen at (15,20)

Pass verify=True to emit memory_read probes (gold_remaining / current_room /
thief col,row) after each beat instead of the clean screenshots.
"""
import json, os, sys

VERIFY = "--verify" in sys.argv
SNA = os.path.abspath("shadowkeep-warden-closed.sna")
OUT = "capture/closed-win.script.json"
ART = os.path.abspath("capture/artefacts")
BLOCK = 36912  # current_room@+0, gold_remaining@+5, thief_col@+7, thief_row@+8

steps = []


def load():   steps.append({"action": "load_snapshot", "path": SNA})
def run(n):   steps.append({"action": "run_frames", "frames": n})
def press(k): steps.append({"action": "input", "events": [{"Key": {"name": k, "pressed": True}}]})
def release(k): steps.append({"action": "input", "events": [{"Key": {"name": k, "pressed": False}}]})
def probe():  steps.append({"action": "memory_read", "addr": BLOCK, "len": 9})
def shot(name): steps.append({"action": "save_screenshot", "path": os.path.join(ART, name)})


def move(k, n):
    press(k); run(n); release(k)
    if VERIFY:
        probe()


def beat(name):
    if not VERIFY:
        shot(name)


# --- title -> Hall ---
load()
run(100)
press("Space"); run(5); release("Space")
run(22)                   # Hall draw completes; Warden gathering at (26,11)
if VERIFY:
    probe()               # expect room0 gold6 thief(15,11)

# HALL: bottom coin (26,20), then top coin (26,6), then exit east
move("A", 9)              # (15,11) -> (15,20)
move("P", 11)             # -> (26,20)  COIN 1
move("O", 1)              # -> (25,20)  (off the Warden's column to climb)
move("Q", 14)             # -> (25,6)
move("P", 1)              # -> (26,6)   COIN 2
move("P", 1)              # -> (27,6)   begin exit
move("A", 5)              # -> (27,11)
move("P", 4)              # -> col31 -> east door -> Gallery (1,11)
beat("win-1-hall-cleared.png")

# GALLERY: coins (24,11) then (24,20), exit north via the col-15 gap
run(22)                   # Gallery draw completes; Warden gathering at (24,15)
move("P", 23)             # (1,11) -> (24,11)  COIN 3
move("O", 1)              # -> (23,11)
move("A", 9)              # -> (23,20)
move("P", 1)              # -> (24,20)  COIN 4
move("O", 9)              # -> (15,20)  head for the col-15 gap (away from col 24)
move("Q", 20)             # up col 15 through the row-8 gap -> north door -> Vault (15,22)
beat("win-2-gallery-cleared.png")

# VAULT: coins (10,20) then (20,20). Sixth coin wins.
run(22)                   # Vault draw completes; Warden gathering at (15,20)
move("O", 5)              # (15,22) -> (10,22)
move("Q", 2)              # -> (10,20)  COIN 5
move("A", 2)              # -> (10,22)
move("P", 10)             # -> (20,22)
move("Q", 2)              # -> (20,20)  COIN 6 -> all gold gone -> win
run(30)                   # show_win renders
if VERIFY:
    probe()
beat("win-3-keep-stands.png")

json.dump(steps, open(OUT, "w"), indent=1)
tmp = "/private/tmp/claude-501/-Users-stevehill-Projects-198x-Code198x/a0aff6a3-eb3d-4349-8969-edfa5b91b829/scratchpad/win-abs.json"
json.dump(steps, open(tmp, "w"))
print(f"wrote {OUT} and {tmp} ({len(steps)} steps){' [VERIFY]' if VERIFY else ''}")
