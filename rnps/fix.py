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

# Implements generic FIX protocol.
#
# Each message is a collection of tag+value pairs.  Tags are integers,
# but values are converted to strings when they're set (if not
# before).  The pairs are maintained in order of creation.  Duplicates
# and repeating groups are allowed.
#
# If tags 8, 9 or 10 are not supplied, they will be automatically
# added in the correct location, and with correct values.  You can
# supply these tags in the wrong order for testing error handling.

########################################################################

import errors


########################################################################

# FIX field delimiter character.
SOH = '\001'

class FixParser(object):

    def __init__(self):
        self.buf = ''
        self.pairs = []
        return

    def append_buf(self, buf):
        self.buf += buf
        return

    def get_message(self):
        # Break buffer into tag=value pairs.
        pairs = self.buf.split(SOH)
        if len(pairs) > 0:
            self.pairs.append(pairs[:-1])
            if pairs[-1] == '':
                self.buf = ''
            else:
                self.buf = pairs[-1]

        if len(self.pairs) == 0:
            return None

        # Check first pair is FIX BeginString.
        while self.pairs[0][:6] != "8=FIX.":
            # Discard pairs until we find the beginning of a message.
            self.pairs.pop(0)

        if len(self.pairs) == 0:
            return None

        # Look for checksum.
        index = 0
        while index < len(self.pairs) and self.pairs[index][:3] != "10=":
            index += 1

        if index == len(self.pairs):
            return None

        # Found checksum, so we have a complete message.
        major = int(pairs[0][6])
        minor = int(pairs[0][8])
        m = FixMessage(major, minor)
        m.append_pairs(self.pairs[:index + 1])
        
        self.pairs = self.pairs[index:]
        
        return m


class FixMessage(object):

    def __init__(self, major, minor):
        self.major = major
        self.minor = minor

        self.message_type = 0
        self.body_length = 0
        self.checksum = 0
        self.pairs = []
        return

    def set_message_type(self, message_type):
        self.message_type = message_type
        return

    def set_body_length(self, body_length):
        self.body_length = 0
        return

    def set_checksum(self, checksum):
        self.checksum = checksum
        return

    def append_pair(self, tag, value):
        self.pairs.append(tuple(str(tag), str(value)))
        return

    def append_strings(self, string_list):
        for s in string_list:
            l = s.split('=', 1)
            if len(l) != 2:
                continue
            self.pairs.append(tuple(str(l[0]), str(l[1])))
        return

    def to_buf(self):
        # Walk pairs, creating string.
        s = ''
        for tag, value in pairs:
            s += '%s=%s' % (tag, value)
            s += SOH

        # Set message type.
        s = "35=%s" % self.message_type + SOH + s

        # Calculate and pre-pend body length.
        #
        # From first byte after body length field, to the delimiter
        # before the checksum (which should be there yet).
        if self.body_length:
            body_length = self.body_length
        else:
            body_length = len(s)
            
        s = \
          "8=FIX.%u.%u" % (self.major, self.minor) + SOH + \
          "9=%u" % body_length + SOH 

        # Calculate and append checksum
        checksum = 0
        for c in s:
            checksum += c
        s += "10=%03u" % (checksum % 256,) + SOH

        return s


########################################################################
