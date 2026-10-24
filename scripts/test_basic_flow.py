"""Independent state/queue invariants and retained native rejection controls."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-components.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)


class Components(unittest.TestCase):
    def test_all_native_evidence_and_rejections(self) -> None:
        for topic in ["game-flow"]:
            C.select(topic)
            C.qualify()

    def test_flow_priority_and_edges(self) -> None:
        C.select("game-flow")
        m = C.M
        for state in range(4):
            for events in range(16):
                target, changed, fresh, error = m.transition(state, events)
                self.assertEqual(error, 0)
                self.assertIn(target, range(4))
                self.assertEqual(changed, int(target != state))
                self.assertEqual(
                    fresh,
                    int(
                        (state == 0 and events & 1 != 0)
                        or (state == 2 and events & 8 != 0)
                    ),
                )
        self.assertEqual(m.transition(1, 6), (2, 1, 0, 0))
        self.assertEqual(m.transition(2, 9), (1, 1, 1, 0))
        self.assertEqual(m.transition(3, 2), (1, 1, 0, 0))
        self.assertNotEqual(m.packet("demo"), m.packet("wrong"))
        self.assertEqual(m.packet("demo"), m.packet("repaired"))


if __name__ == "__main__":
    unittest.main()
