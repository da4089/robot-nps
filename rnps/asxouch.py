########################################################################
# robot-nps, Network Protocol Simulator for Robot Framework
#
# Copyright (C) 2015-2016 David Arnold
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

# Implements ASX OUCH SR8 as at 2015/04/25.
#
# ASX OUCH is implemented by NASDAQ OMX's Genium INET platform, as
# deployed for ASX.  It's based on NASDAQ's OUCH4, but has a bunch of
# extra fields.
#
# Source documents:
# - ASX Trade OUCH v1.0 (document #036435).
# - ASX OUCH Message Specification, v2.0, 2 September 2013.
# - ASX Trade OUCH Specification, Q2 2015 Release - SR8, 18 March 2015.
# - ASX Trade Q2 2015 Release (SR8) Appendices to ASX Notice.

########################################################################

import struct
import errors

from ouch4 import OuchMessage


########################################################################

def get_message(soup_type, buf):
    if len(buf) < 1:
        return None

    if soup_type == 'S':
        constructor = SEQUENCED_MESSAGES.get(buf[0])
    elif soup_type == 'U':
        constructor = UNSEQUENCED_MESSAGES.get(buf[0])
    else:
        return None

    if not constructor:
        return None

    msg = constructor()
    msg.decode(buf)
    return msg


########################################################################

class EnterOrder(OuchMessage):
    _format = '!c 14s L c Q L B B 10s 15s 32s c L c c 4s 10s 20s 8s c Q Q'
    _ouch_type = 'O'

    def __init__(self):
        self.order_token = ''
        self.order_book_id = 0
        self.side = ''
        self.quantity = 0
        self.price = 0
        self.time_in_force = 0
        self.open_close = 0
        self.client_account = ''
        self.customer_info = ''
        self.exchange_info = ''
        self.clearing_participant = ''
        self.crossing_key = 0
        self.capacity = ''
        self.directed_wholesale = ''
        self.execution_venue = ''
        self.intermediary_id = ''
        self.order_origin = ''
        self.filler = '        '
        self.order_type = ''
        self.short_sell_quantity = 0
        self.minimum_acceptable_quantity = 0
        return

    def encode(self):
        print "AAAAAAAAAAAAAAAAA"
        l = [self._format,
                           self._ouch_type,
                           self.order_token.ljust(14),
                           self.order_book_id,
                           self.side,
                           self.quantity,
                           self.price,
                           self.time_in_force,
                           self.open_close,
                           self.client_account,
                           self.customer_info,
                           self.exchange_info,
                           self.clearing_participant,
                           self.crossing_key,
                           self.capacity,
                           self.directed_wholesale,
                           self.execution_venue,
                           self.intermediary_id,
                           self.order_origin,
                           self.filler,
                           self.order_type,
                           self.short_sell_quantity,
                           self.minimum_acceptable_quantity]
        for i in l:
            print type(i), i


        return struct.pack(self._format,
                           self._ouch_type,
                           self.order_token.ljust(14),
                           self.order_book_id,
                           self.side,
                           self.quantity,
                           self.price,
                           self.time_in_force,
                           self.open_close,
                           self.client_account,
                           self.customer_info,
                           self.exchange_info,
                           self.clearing_participant,
                           self.crossing_key,
                           self.capacity,
                           self.directed_wholesale,
                           self.execution_venue,
                           self.intermediary_id,
                           self.order_origin,
                           self.filler,
                           self.order_type,
                           self.short_sell_quantity,
                           self.minimum_acceptable_quantity)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.order_token = fields[1].strip()
        self.order_book_id = int(fields[2])
        self.side = fields[3]
        self.quantity = int(fields[4])
        self.price = int(fields[5])
        self.time_in_force = int(fields[6])
        self.open_close = int(fields[7])
        self.client_account = fields[8].strip()
        self.customer_info = fields[9].strip()
        self.exchange_info = fields[10].strip()
        self.clearing_participant = fields[11]
        self.crossing_key = int(fields[12])
        self.capacity = fields[13]
        self.directed_wholesale = fields[14]
        self.execution_venue = fields[15]
        self.intermediary_id = fields[16].strip()
        self.order_origin = fields[17].strip()
        # filler (8 spaces)
        self.order_type = fields[19]
        self.short_sell_quantity = int(fields[20])
        self.minimum_acceptable_quantity = int(fields[21])
        return


class ReplaceOrder(OuchMessage):
    _format = '!c 14s 14s Q L B 10s 15s 32s c c 4s 10s 20s 8s Q Q'
    _ouch_type = 'U'

    def __init__(self):
        self.existing_order_token = ''
        self.replacement_order_token = ''
        self.quantity = 0
        self.price = 0
        self.open_close = 0
        self.client_account = ''
        self.customer_info = ''
        self.exchange_info = ''
        self.capacity = ''
        self.directed_wholesale = ''
        self.execution_venue = ''
        self.intermediary_id = ''
        self.order_origin = ''
        self.filler = '        '
        self.short_sell_quantity = 0
        self.minimum_acceptable_quantity = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.existing_order_token.ljust(14),
                           self.replacement_order_token.ljust(14),
                           self.quantity,
                           self.price,
                           self.open_close,
                           self.client_account,
                           self.customer_info,
                           self.exchange_info,
                           self.capacity,
                           self.directed_wholesale,
                           self.execution_venue,
                           self.intermediary_id,
                           self.order_origin,
                           self.filler,
                           self.short_sell_quantity,
                           self.minimum_acceptable_quantity)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.existing_order_token = fields[1].strip()
        self.replacement_order_token = fields[2].strip()
        self.quantity = int(fields[3])
        self.price = int(fields[4])
        self.open_close = int(fields[5])
        self.client_account = fields[6]
        self.customer_info = fields[7]
        self.exchange_info = fields[8]
        self.capacity = fields[9]
        self.directed_wholesale = fields[10]
        self.execution_venue = fields[11]
        self.intermediary_id = fields[12]
        self.order_origin = fields[13]
        # filler
        self.short_sell_quantity = int(fields[15])
        self.minimum_acceptable_quantity = int(fields[16])
        return


class CancelOrder(OuchMessage):
    _format = '!c 14s'
    _ouch_type = 'X'

    def __init__(self):
        self.order_token = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.order_token.ljust(14))

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.order_token = fields[1].strip()
        return


class CancelByOrderId(OuchMessage):
    _format = '!c L c Q'
    _ouch_type = 'Y'

    def __init__(self):
        self.order_book_id = 0
        self.side = ''
        self.order_id = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.order_book_id,
                           self.side,
                           self.order_id)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.order_book_id = int(fields[1])
        self.side = fields[2]
        self.order_id = int(fields[3])
        return


class Accepted(OuchMessage):
    _format = '!c Q 14s L c Q Q L B B 10s B 15s 32s c L c c 4s 10s 20s 8s c Q Q'
    _ouch_type = 'A'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.order_book_id = 0
        self.side = ''
        self.order_id = 0
        self.quantity = 0
        self.price = 0
        self.time_in_force = 0
        self.open_close = 0
        self.client_account = ''
        self.order_state = 0
        self.customer_info = ''
        self.exchange_info = ''
        self.clearing_participant = ''
        self.crossing_key = 0
        self.capacity = ''
        self.directed_wholesale = ''
        self.execution_venue = ''
        self.intermediary_id = ''
        self.order_origin = ''
        self.filler = '        '
        self.order_type = ''
        self.short_sell_quantity = 0
        self.minimum_acceptable_quantity = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14),
                           self.order_book_id,
                           self.side,
                           self.order_id,
                           self.quantity,
                           self.price,
                           self.time_in_force,
                           self.open_close,
                           self.client_account,
                           self.order_state,
                           self.customer_info,
                           self.exchange_info,
                           self.clearing_participant,
                           self.crossing_key,
                           self.capacity,
                           self.directed_wholesale,
                           self.execution_venue,
                           self.intermediary_id,
                           self.order_origin,
                           self.filler,
                           self.order_type,
                           self.short_sell_quantity,
                           self.minimum_acceptable_quantity)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        self.order_book_id = fields[3]
        self.side = fields[4]
        self.order_id = fields[5]
        self.quantity = fields[6]
        self.price = fields[7]
        self.time_in_force = fields[8]
        self.open_close = fields[9]
        self.client_account = fields[10]
        self.order_state = fields[11]
        self.customer_info = fields[12]
        self.exchange_info = fields[13]
        self.clearing_participant = fields[14]
        self.crossing_key = fields[15]
        self.capacity = fields[16]
        self.directed_wholesale = fields[17]
        self.execution_venue = fields[18]
        self.intermediary_id = fields[19].strip()
        self.order_origin = fields[20].strip()
        # filler (8 spaces)
        self.order_type = fields[22]
        self.short_sell_quantity = fields[23]
        self.minimum_acceptable_quantity = fields[24]
        return


class Replaced(OuchMessage):
    _format = '!c Q 14s 14s L c Q Q L B B 10s B 15s 32s c L ' + \
              'c c 4s 10s 20s 8s c Q Q'
    _ouch_type = 'U'

    def __init__(self):
        self.timestamp = 0
        self.replacement_order_token = ''
        self.previous_order_token = ''
        self.order_book_id = 0
        self.side = ''
        self.order_id = 0
        self.quantity = 0
        self.price = 0
        self.time_in_force = 0
        self.open_close = 0
        self.client_account = ''
        self.order_state = 0
        self.customer_info = ''
        self.exchange_info = ''
        self.clearing_participant = ''
        self.crossing_key = 0
        self.capacity = ''
        self.directed_wholesale = ''
        self.execution_venue = ''
        self.intermediary_id = ''
        self.order_origin = ''
        self.filler = ' ' * 8
        self.order_type = ''
        self.short_sell_quantity = 0
        self.minimum_acceptable_quantity = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.replacement_order_token.ljust(14),
                           self.previous_order_token.ljust(14),
                           self.order_book_id,
                           self.side,
                           self.order_id,
                           self.quantity,
                           self.price,
                           self.time_in_force,
                           self.open_close,
                           self.customer_info.ljust(15),
                           self.exchange_info.ljust(32),
                           self.clearing_participant,
                           self.crossing_key,
                           self.capacity,
                           self.directed_wholesale,
                           self.execution_venue.ljust(4),
                           self.intermediary_id.ljust(10),
                           self.order_origin.ljust(20),
                           self.filler.ljust(8),
                           self.order_type,
                           self.short_sell_quantity,
                           self.minimum_acceptable_quantity)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.replacement_order_token = fields[2].strip()
        self.previous_order_token = fields[3].strip()
        self.order_book_id = fields[4]
        self.side = fields[5]
        self.order_id = fields[6]
        self.quantity = fields[7]
        self.price = fields[8]
        self.time_in_force = fields[9]
        self.open_close = fields[10]
        self.client_account = fields[11].strip()
        self.order_state = fields[12]
        self.customer_info = fields[13].strip()
        self.exchange_info = fields[14].strip()
        self.clearing_participant = fields[15].strip()
        self.crossing_key = fields[16]
        self.capacity = fields[17]
        self.directed_wholesale = fields[18]
        self.execution_venue = fields[19].strip()
        self.intermediary_id = fields[20].strip()
        self.order_origin = fields[21].strip()
        # filler
        self.order_type = fields[23]
        self.short_sell_quantity = fields[24]
        self.minimum_acceptable_quantity = fields[25]
        return


class Canceled(OuchMessage):
    _format = '!c Q 14s L c Q B'
    _ouch_type = 'C'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.order_book_id = 0
        self.side = ''
        self.order_id = 0
        self.reason = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14),
                           self.order_book_id,
                           self.side,
                           self.order_id,
                           self.reason)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        self.order_book_id = fields[3]
        self.side = fields[4]
        self.order_id = fields[5]
        self.reason = fields[6]
        return


class Executed(OuchMessage):
    _format = '!c Q 14s L Q L 12B H B'
    _ouch_type = 'E'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.order_book_id = 0
        self.traded_quantity = 0
        self.trade_price = 0
        self.match_id = 0
        self.deal_source = 0
        self.match_attributes = 0
        return

    def encode(self):
        m =  chr((self.match_id >> 88) & 0xff)
        m += chr((self.match_id >> 80) & 0xff)
        m += chr((self.match_id >> 72) & 0xff)
        m += chr((self.match_id >> 64) & 0xff)

        m += chr((self.match_id >> 56) & 0xff)
        m += chr((self.match_id >> 48) & 0xff)
        m += chr((self.match_id >> 40) & 0xff)
        m += chr((self.match_id >> 32) & 0xff)

        m += chr((self.match_id >> 24) & 0xff)
        m += chr((self.match_id >> 16) & 0xff)
        m += chr((self.match_id >>  8) & 0xff)
        m += chr((self.match_id >>  0) & 0xff)

        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14),
                           self.order_book_id,
                           self.traded_quantity,
                           self.trade_price,
                           m,
                           self.deal_source,
                           self.match_attributes)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        self.order_book_id = fields[3]
        self.traded_quantity = fields[4]
        self.trade_price = fields[5]
        m = fields[6]
        self.deal_source = fields[7]
        self.match_attributes = fields[8]

        match_id = 0
        if True:
            for i in range(12):
                match_id |= ord(m[i])
                if i < 11:
                    match_id = match_id << 8
        else:
            match_id = 0
            match_id |= ord(m[0]) << 88
            match_id |= ord(m[1]) << 80
            match_id |= ord(m[2]) << 72
            match_id |= ord(m[3]) << 64

            match_id |= ord(m[4]) << 56
            match_id |= ord(m[5]) << 48
            match_id |= ord(m[6]) << 40
            match_id |= ord(m[7]) << 32

            match_id |= ord(m[8]) << 24
            match_id |= ord(m[9]) << 16
            match_id |= ord(m[10]) << 8
            match_id |= ord(m[11])

        self.match_id = match_id
        return


class Rejected(OuchMessage):
    _format = '!c Q 14s L'
    _ouch_type = 'J'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.reject_code = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14),
                           self.reject_code)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        self.reject_code = fields[3]
        return


UNSEQUENCED_MESSAGES = {
    "O": EnterOrder,
    "U": ReplaceOrder,
    "X": CancelOrder,
    "Y": CancelByOrderId,
}

SEQUENCED_MESSAGES = {
    "A": Accepted,
    "C": Canceled,
    "E": Executed,
    "J": Rejected,
    "U": Replaced,
}

INTEGER_FIELDS = [
    "crossing_key",
    "deal_source",
    "match_attributes",
    "match_id",
    "minimum_acceptable_quantity",
    "open_close",
    "order_book_id",
    "order_id",
    "order_state",
    "price",
    "quantity",
    "reason",
    "reject_code",
    "short_sell_quantity",
    "time_in_force",
    "timestamp",
    "trade_price",
    "traded_quantity"
]


########################################################################
