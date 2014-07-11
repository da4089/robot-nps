########################################################################
########################################################################

import struct


class ClientHeartbeat:
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

class Debug:
    _format = '!Hc'
    _type = '+'

    def __init__(self):
        self.text = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           len(self.Text) + 1,
                           self._type) + self.text

    def decode(self, buf):
        fields = struct.unpack(self._format, buf[:3])
        soup_len = fields[0]
        assert fields[1] == self._type

        # Bytes 0 & 1 are len, 2 is type, 3+ are payload.
        # Length: +1 for type, +1 for Python slicing.
        self.text = buf[3:soup_len + 2] 
        return


class EndOfSession:
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


class LoginAccepted:
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
        self.session = fields[2]
        self.sequence_number = int(fields[3])
        return


class LoginRejected:
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


class SequencedData:
    _format = '!Hc'
    _type = 'S'

    def __init__(self):
        self.message = ''
        self._OuchMessage = None
        return

    def encode(self):
        self.message = self._OuchMessage.encode()
        return struct.pack(self._format,
                           len(self.message) + 1,
                           self._type) + self.message

    def decode(self, buf):
        fields = struct.unpack(self._format, buf[:3])
        l = fields[0]
        assert fields[1] == self._type
        self.Message = buf[3:l - 1 + 3]

        factory = OUCH.SequencedMessages.get(self.Message[0])
        if not factory:
            raise BadOuchTypeError(self.Message[0])

        self._OuchMessage = factory()
        print self._OuchMessage
        self._OuchMessage.decode(self.Message)
        return


class ServerHeartbeat:
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


class LoginRequest:
    _format = '!Hc6s10s10s20s'
    _type = 'L'

    def __init__(self):
        self.Username = ''
        self.Password = ''
        self.RequestedSession = ''
        self.RequestedSequenceNumber = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           47,
                           self._type,
                           self.Username.ljust(6),
                           self.Password.ljust(10),
                           self.RequestedSession.ljust(10),
                           str(self.RequestedSequenceNumber).rjust(20))

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == 47
        assert fields[1] == self._type
        self.Username = fields[2]
        self.Password = fields[3]
        self.RequestedSession = fields[4]
        self.RequestedSequenceNumber = fields[5]
        return


class UnsequencedData:
    _format = '!Hc'
    _type = 'U'

    def __init__(self):
        self.Message = ''
        self._OuchMessage = None
        return

    def encode(self):
        self.Message = self._OuchMessage.encode()
        return struct.pack(self._format,
                           len(self.Message) + 1,
                           self._type) + self.Message

    def decode(self, buf):
        fields = struct.unpack(self._format, buf[0:3])
        l = fields[0]
        assert fields[1] == self._type
        self.Message = buf[3:l - 1 + 3]

        factory = OUCH.UnsequencedMessages.get(self.Message[0])
        assert factory

        self._OuchMessage = factory()
        self._OuchMessage.decode(self.Message)
        return


class LogoutRequest:
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


Messages = {
    "+": Debug,
    "A": LoginAccepted,
    "H": ServerHeartbeat,
    "J": LoginRejected,
    "L": LoginRequest,
    "O": LogoutRequest
    "R": ClientHeartbeat,
    "S": SequencedData,
    "U": UnsequencedData,
    "Z": EndOfSession,
}


