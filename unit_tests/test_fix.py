########################################################################
# robot-nps, Network Protocol Simulator for Robot Framework
#
# Copyright (C) 2015 David Arnold
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################

import unittest
from rnps import fix


class FixTests(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_basic_fix_message(self):
        pkt = fix.FixMessage()
        pkt.set_session_version("FIX.4.2")
        pkt.set_message_type('D')
        pkt.append_pair(29, "A")
        buf = pkt.encode()

        p = fix.FixParser()
        p.append_buffer(buf)
        m = p.get_message()

        self.assertIsNotNone(m)
        self.assertEqual(pkt, m)
        return

    def test_raw_empty_message(self):
        pkt = fix.FixMessage()
        pkt.set_raw()
        self.assertEqual("", pkt.encode())
        return

    def test_raw_begin_string(self):
        pkt = fix.FixMessage()
        pkt.set_raw()
        pkt.append_pair(8, "FIX.4.4")
        self.assertEqual("8=FIX.4.4\x01", pkt.encode())
        return

    def test_set_session_version(self):
        pkt = fix.FixMessage()
        pkt.set_session_version("FIX.4.4")
        self.assertEqual("8=FIX.4.4\x019=5\x0135=0\x0110=163\x01", pkt.encode())
        return

    def test_get_repeating(self):
        pkt = fix.FixMessage()
        pkt.append_pair(42, "a")
        pkt.append_pair(42, "b")
        pkt.append_pair(42, "c")

        self.assertEqual("a", pkt.get(42))
        self.assertEqual("b", pkt.get(42, 2))
        self.assertEqual("c", pkt.get(42, 3))
        self.assertEqual("a", pkt.get(42, 1))
        self.assertIsNone(pkt.get(42, 4))
        return

    def test_raw_body_length(self):
        pkt = fix.FixMessage()
        pkt.set_raw()
        pkt.append_pair(9, 42)
        self.assertEqual("9=42\x01", pkt.encode())
        return

    def test_raw_checksum(self):
        pkt = fix.FixMessage()
        pkt.set_raw()
        pkt.append_pair(10, 42)
        self.assertEqual("10=42\x01", pkt.encode())
        return

    def test_raw_msg_type(self):
        pkt = fix.FixMessage()
        pkt.set_raw()
        pkt.append_pair(35, "D")
        self.assertEqual("35=D\x01", pkt.encode())
        return

    def test_empty_message(self):
        pkt = fix.FixMessage()
        self.assertEqual("8=FIX.4.2\x019=5\x0135=0\x0110=161\x01", pkt.encode())
        return



suite = unittest.TestSuite()
suite.addTests(unittest.makeSuite(FixTests))

if __name__ == "__main__":
    runner = unittest.TextTestRunner()
    runner.run(suite)

