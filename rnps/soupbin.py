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

# Implements NASDAQ SoupBinTCP 3.0 2008/10/15.
#
# SoupBinTCP is a simple framing protocol used by NASDAQ's OUCH 4.x series
# of order entry protocols.  It uses a 16 bit, big-endian binary length
# field in the header to frame its encapsulated message.  Consequently, and
# unlike SoupTCP, it can carry any application payload, and does not require
# scanning for the message terminator to determine the message length.
#
# Compare with SoupTCP and UFO from NASDAQ, and MEP from DirectEdge.

########################################################################

import struct


########################################################################

def has_complete_message(buf):
    if len(buf) < 3:
        # SoupBin header is 3 bytes.
        return False

    length, soup_type = struct.unpack("!Hc", buf[:3])
    if len(buf) < length + 2:
        # SoupBin header length field is count of following bytes (so + 2).
        return False

    if buf[2] not in Messages.keys():
        # Unrecognised SoupBin message type code.
        return False

    return True


def get_message(buf):
    if len(buf) < 3:
        return None, buf

    soup_length, soup_type = struct.unpack("!Hc", buf[:3])
    if len(buf) < soup_length + 2:
        return None, buf

    constructor = Messages.get(buf[2])
    if not constructor:
        return None, buf

    soup_buf = buf[:soup_length + 2]
    buf = buf[soup_length + 2:]

    msg = constructor()
    msg.decode(soup_buf)

    return msg, buf


class SoupMessage(object):
    _type = None

    def get_type(self):
        return self._type

    def has_payload(self):
        return hasattr(self, "_payload")

    def set_payload(self, payload):
        self._payload = payload
        return

    def get_payload(self):
        return None if not self.has_payload() else self._payload


class ClientHeartbeat(SoupMessage):
    _format = '!Hc'
    _type = 'R'

    def __init__(self):
        return

    def encode(self):
        return struct.pack(self._format, 1, self._type)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == 1
        assert fields[1] == self._type
        return


class Debug(SoupMessage):
    _format = '!Hc'
    _type = '+'

    def __init__(self):
        self.text = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           len(self.text) + 1,
                           self._type) + self.text

    def decode(self, buf):
        fields = struct.unpack(self._format, buf[:3])
        soup_len = fields[0]
        assert fields[1] == self._type

        # Bytes 0 & 1 are len, 2 is type, 3+ are payload.
        # Length: +1 for type, +1 for Python slicing.
        self.text = buf[3:soup_len + 2] 
        return


class EndOfSession(SoupMessage):
    _format = '!Hc'
    _type = 'Z'

    def __init__(self):
        return

    def encode(self):
        return struct.pack(self._format, 1, self._type)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == 1
        assert fields[1] == self._type
        return


class LoginAccepted(SoupMessage):
    _format = '!Hc10s20s'
    _type = 'A'

    def __init__(self):
        self.session = ''
        self.sequence_number = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           31,
                           self._type,
                           self.session.ljust(10),
                           str(self.sequence_number).ljust(20))

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == 31
        assert fields[1] == self._type
        self.session = fields[2].strip()
        self.sequence_number = int(fields[3])
        return


class LoginRejected(SoupMessage):
    _format = '!Hcc'
    _type = 'J'

    NOT_AUTHORIZED = 'A'
    NOT_AVAILABLE = 'S'

    def __init__(self):
        self.reject_reason_code = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           2,
                           self._type,
                           self.reject_reason_code)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == 2
        assert fields[1] == self._type
        self.reject_reason_code = fields[2]
        return


class LoginRequest(SoupMessage):
    _format = '!Hc6s10s10s20s'
    _type = 'L'

    def __init__(self):
        self.username = ''
        self.password = ''
        self.requested_session = ''
        self.requested_sequence_number = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           47,
                           self._type,
                           self.username.ljust(6),
                           self.password.ljust(10),
                           self.requested_session.ljust(10),
                           str(self.requested_sequence_number).rjust(20))

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == 47
        assert fields[1] == self._type
        self.username = fields[2].strip()
        self.password = fields[3].strip()
        self.requested_session = fields[4].strip()
        self.requested_sequence_number = int(fields[5])
        return


class LogoutRequest(SoupMessage):
    _format = '!Hc'
    _type = 'O'

    def __init__(self):
        return

    def encode(self):
        return struct.pack(self._format, 1, self._type)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == 1
        assert fields[1] == self._type
        return


class SequencedData(SoupMessage):
    _format = '!Hc'
    _type = 'S'

    def __init__(self):
        self.message = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           len(self.message) + 1,
                           self._type) + self.message

    def decode(self, buf):
        fields = struct.unpack(self._format, buf[:3])
        length = fields[0] - 1
        assert fields[1] == self._type
        self.message = buf[3:length + 3]
        return


class ServerHeartbeat(SoupMessage):
    _format = '!Hc'
    _type = 'H'

    def __init__(self):
        return

    def encode(self):
        return struct.pack(self._format, 1, self._type)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == 1
        assert fields[1] == self._type
        return


class UnsequencedData(SoupMessage):
    _format = '!Hc'
    _type = 'U'

    def __init__(self):
        self.message = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           len(self.message) + 1,
                           self._type) + self.message

    def decode(self, buf):
        fields = struct.unpack(self._format, buf[0:3])
        length = fields[0] - 1
        assert fields[1] == self._type
        self.message = buf[3:length + 3]
        return


########################################################################

Messages = {
    "+": Debug,
    "A": LoginAccepted,
    "H": ServerHeartbeat,
    "J": LoginRejected,
    "L": LoginRequest,
    "O": LogoutRequest,
    "R": ClientHeartbeat,
    "S": SequencedData,
    "U": UnsequencedData,
    "Z": EndOfSession,
}


########################################################################
