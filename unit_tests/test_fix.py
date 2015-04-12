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
        pkt = fix.FixMessage(4, 2)
        pkt.set_message_type('D')
        buf = pkt.to_buf()

        fix.print_fix(buf)

        p = fix.FixParser()
        p.append_buffer(buf)
        m = p.get_message()

        print pkt.pairs
        print m.pairs

        self.assertIsNotNone(m)
        self.assertEqual(pkt, m)
        return

