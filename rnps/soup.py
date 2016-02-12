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

# Implements NASDAQ SoupTcp 3.0 - 2014/03/20.
#
# SoupTCP is a simple framing protocol used by NASDAQ's OUCH 3.x series
# order entry protocols.  It is an ASCII-based protocol, with numeric
# quantities represented as strings of ASCII digits; and using a
# trailing LF character to indicate the end of a message body.
#
# Compare with SoupBin (with explicit lengths and binary numbers) and
# UFO (a UDP-based encapsulation).

########################################################################

import struct


########################################################################

LF = '\n'

class ClientHeartbeat(object):
    _type = 'R'

    def __init__(self):
        return

    def encode(self):
        return self._type + LF

    def decode(self, buf):
        assert buf[0] == self._type
        assert buf[1] == LF
        return


class Debug(object):
    _type = '+'

    def __init__(self):
        self.text = ''
        return

    def encode(self):
        return self._type + self.text + LF

    def decode(self, buf):
        assert buf[0] == self._type
        i = 1
        while i < len(buf):
            if buf[i] != LF:
                i += 1
                continue
            self.text = buf[1:i]
            break

        assert buf[i] == LF
        return


class EndOfSession(object):
    _type = 'Z'

    def __init__(self):
        return

    def encode(self):
        return self._type + LF

    def decode(self, buf):
        assert buf[0] == self._type
        assert buf[1] == LF
        return


class LoginAccepted(object):
    _format = 'c10s20sc'
    _type = 'A'

    def __init__(self):
        self.session = ''
        self.sequence_number = 0
        return

    def encode(self):
        return self._type + self.session.rjust(10, ' ') + str(self.sequence_number).rjust(20) + LF

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._type
        self.session = fields[1].strip()
        self.sequence_number = int(fields[2])
        assert fields[3] == LF
        return


class LoginRejected(object):
    _format = 'ccc'
    _type = 'J'

    NOT_AUTHORIZED = 'A'
    NOT_AVAILABLE = 'S'

    def __init__(self):
        self.reject_reason_code = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._type,
                           self.reject_reason_code,
                           LF)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._type
        self.reject_reason_code = fields[1]
        assert fields[2] == LF
        return


class LoginRequest(object):
    _format = 'c6s10s10s20sc'
    _type = 'L'

    def __init__(self):
        self.username = ''
        self.password = ''
        self.requested_session = ''
        self.requested_sequence_number = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._type,
                           self.username.ljust(6),
                           self.password.ljust(10),
                           self.requested_session.ljust(10),
                           str(self.requested_sequence_number).rjust(20),
                           LF)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._type
        self.username = fields[1].strip()
        self.password = fields[2].strip()
        self.requested_session = fields[3].strip()
        self.requested_sequence_number = int(fields[4])
        assert fields[5] == LF
        return


class LogoutRequest(object):
    _format = 'cc'
    _type = 'O'

    def __init__(self):
        return

    def encode(self):
        return struct.pack(self._format, self._type, LF)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._type
        assert fields[1] == LF
        return


class SequencedData(object):
    _type = 'S'

    def __init__(self):
        self.message = ''
        return

    def encode(self):
        return self._type + self.message + LF

    def decode(self, buf):
        assert buf[0] == self._type
        i = 1
        while i < len(buf):
            if buf[i] != LF:
                i += 1
                continue
            self.message = buf[1:i]
            break

        assert buf[i] == LF
        return


class ServerHeartbeat(object):
    _format = 'cc'
    _type = 'H'

    def __init__(self):
        return

    def encode(self):
        return struct.pack(self._format,
                           self._type,
                           LF)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._type
        assert fields[1] == LF
        return


class UnsequencedData(object):
    _type = 'U'

    def __init__(self):
        self.message = ''
        return

    def encode(self):
        return self._type + self.message + LF

    def decode(self, buf):
        assert buf[0] == self._type
        i = 1
        while i < len(buf):
            if buf[i] != LF:
                i += 1
                continue
            self.message = buf[1:i]
            break

        assert buf[i] == LF
        return


########################################################################

Messages = {
    '+': Debug,
    'A': LoginAccepted,
    'H': ServerHeartbeat,
    'J': LoginRejected,
    'L': LoginRequest,
    'O': LogoutRequest,
    'R': ClientHeartbeat,
    'S': SequencedData,
    'U': UnsequencedData,
    'Z': EndOfSession,
}


########################################################################
