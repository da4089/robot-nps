#! /usr/bin/env python
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

from distutils.core import setup


setup(name="robot-nps",
      version="1.0.0",
      description="Robot Framework Network Protocol Simulator",
      url="https://github.com/da4089/robot-nps",
      author="David Arnold",
      author_email="d+robot-nps@0x1.org",
      packages=["rnps"],
      scripts=["rnps-ouch"])


########################################################################
