########################################################################
# robot-nps, Network Protocol Simulator for Robot Framework
#
# Copyright (C) 2014 David Arnold
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

from test_soupbin import SoupBinTests
from test_soup import SoupTests


suite = unittest.TestSuite()
suite.addTests(unittest.makeSuite(SoupBinTests))
suite.addTests(unittest.makeSuite(SoupTests))


if __name__ == "__main__":
    runner = unittest.TextTestRunner()
    runner.run(suite)

