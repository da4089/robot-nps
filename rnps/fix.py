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


def print_fix(s):
    cooked = s.replace('\x01', '|')
    print cooked


class FixParser(object):

    def __init__(self):
        self.buf = ''
        self.pairs = []
        return

    def append_buffer(self, buf):
        self.buf += buf
        return

    def get_message(self):
        # Break buffer into tag=value pairs.
        pairs = self.buf.split(SOH)
        if len(pairs) > 0:
            self.pairs.extend(pairs[:-1])
            if pairs[-1] == '':
                self.buf = ''
            else:
                self.buf = pairs[-1]

        if len(self.pairs) == 0:
            return None

        # Check first pair is FIX BeginString.
        while self.pairs and self.pairs[0][:6] != "8=FIX.":
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
        m = FixMessage()
        m.append_strings(self.pairs[:index + 1])
        self.pairs = self.pairs[index:]
        
        return m


class FixMessage(object):
    """FIX protocol message.

    FIX messages consist of an ordered list of tag=value pairs.  Tags
    are numbers, represented on the wire as strings.  Values may have
    various types, again all presented as strings on the wire.

    This class stores a FIX message: it does not perform any validation
    of the content of tags or values, nor the presence of tags required
    for compliance with a specific FIX protocol version."""

    def __init__(self):
        """Initialise a FIX message."""

        self.major = 0
        self.minor = 0
        self.message_type = 0
        self.body_length = 0
        self.checksum = 0
        self.pairs = []
        return

    def set_version(self, major, minor):
        """Set FIX protocol version.

        :param major: Major FIX version number (4 or 5).
        :param minor: Minor FIX version number."""

        self.major = int(major)
        self.minor = int(minor)
        return

    def set_message_type(self, message_type):
        """Set FIX message type.

        :param message_type: FIX message type code.

        All messages should have their message type set with this
        function, or by setting a 35=x field, unless testing a scenario
        where the message type is unset."""

        self.message_type = message_type
        return

    def set_body_length(self, body_length):
        """Override calculated body length.

        :param body_length: Body length in bytes.

        This function is useful for testing scenarios requiring an
        incorrect body length in a message."""

        self.body_length = body_length
        return

    def set_checksum(self, checksum):
        """Override calculated checksum value.

        :param checksum: Integer checksum value.

        This function is useful for testing scenarios requiring an
        invalid checksum in a message."""

        self.checksum = checksum
        return

    def append_pair(self, tag, value):
        """Append a tag=value pair to this message.

        :param tag: Integer or string FIX tag number.
        :param value: FIX tag value.

        Both parameters are explicitly converted to strings before
        storage, so it's ok to pass integers if that's easier for
        your program logic."""

        if int(tag) == 8:
            v = str(value)
            if len(v) < len("FIX.x.y"):
                raise ValueError("Bad version: %s" % v)
            self.set_version(int(v[4]), int(v[6]))
            return

        if int(tag) == 9:
            # Ignore body length.
            return

        if int(tag) == 10:
            # Ignore checksum.
            return

        if int(tag) == 35:
            # Promote 35=x to attribute.
            self.message_type = value
            return

        self.pairs.append((str(tag), str(value)))
        return

    def append_string(self, field):
        """Append a tag=value pair in string format.

        :param field: String "tag=value" to be appended to this message.

        The string is split at the first '=' character, and the resulting
        tag and value strings are appended to the message."""

        # Split into tag and value.
        l = field.split('=', 1)
        if len(l) != 2:
            raise ValueError("Field missing '=' separator.")

        # Check tag is an integer.
        try:
            tag_int = int(l[0])
        except ValueError:
            raise ValueError("Tag value must be an integer")

        # Save.
        self.append_pair(tag_int, l[1])
        return

    def append_strings(self, string_list):
        """Append tag=pairs for each supplied string.

        :param string_list: List of "tag=value" strings.

        Each string is split, and the resulting tag and value strings
        are appended to the message."""

        for s in string_list:
            self.append_string(s)
        return

    def get(self, tag):
        """Return first value for tag.

        :param tag: FIX field tag number
        :return: None if nothing found, otherwise value matching tag.

        Note that for repeating groups, this function will only ever
        return the value of the first instance of 'tag' found in the
        message."""

        for t, v in self.pairs:
            if t == tag:
                return v

        return None

    def to_buf(self):
        """Convert message to on-the-wire FIX format."""

        # Walk pairs, creating string.
        s = ''
        for tag, value in self.pairs:
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
            
        s = "8=FIX.%u.%u" % (self.major, self.minor) + SOH + \
            "9=%u" % body_length + SOH + \
            s

        # Calculate and append the checksum.
        checksum = 0
        for c in s:
            checksum += ord(c)
        s += "10=%03u" % (checksum % 256,) + SOH

        return s

    def __eq__(self, other):
        """Compare with another FixMessage.

        :param other: Message to compare.

        Compares the tag=value pairs, message_type and FIX version
        of this message against the `other`."""

        # Compare message versions.
        if self.major != other.major or self.minor != other.minor:
            return False

        # Compare message types.
        if self.message_type != other.message_type:
            return False

        # Check pairs list lengths.
        if len(self.pairs) != len(other.pairs):
            return False

        # Clone our pairs list.
        tmp = []
        for pair in self.pairs:
            tmp.append((pair[0], pair[1]))

        for pair in other.pairs:
            try:
                tmp.remove(pair)
            except ValueError:
                return False

        if len(tmp) > 0:
            return False

        return True

########################################################################
