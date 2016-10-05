########################################################################
# robot-nps, Network Protocol Simulator for Robot Framework
#
# Copyright (C) 2016 David Arnold
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

# Implements BIVA OUCH 1.03, as at 2016/08/23.

########################################################################

import struct
import errors


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

class OuchMessage(object):
    _ouch_type = None

    def get_type(self):
        return self._ouch_type

    def set_field(self, field_name, value):
        if field_name[0:1] == "_" or not hasattr(self, field_name):
            raise errors.BadFieldNameError(field_name)

        setattr(self, field_name, value)
        return

    def has_field(self, field_name):
        return hasattr(self, field_name)

    def get_field(self, field_name):
        if field_name[0:1] == "_" or not hasattr(self, field_name):
            raise errors.BadFieldNameError(field_name)

        return getattr(self, field_name)


class EnterOrder(OuchMessage):
    _format = '!c L c L c Q L L L L Q'
    _ouch_type = 'O'

    def __init__(self):
        self.order_token = 0
        self.account_type = ''
        self.account_id = 0
        self.order_verb = ''
        self.quantity = 0
        self.orderbook = 0
        self.price = 0
        self.time_in_force = 0
        self.client_id = 0
        self.minimum_quantity = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.order_token,
                           self.account_type,
                           self.account_id,
                           self.order_verb,
                           self.quantity,
                           self.orderbook,
                           self.price,
                           self.time_in_force,
                           self.client_id,
                           self.minimum_quantity)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.order_token = fields[1]
        self.account_type = fields[2]
        self.account_id = fields[3]
        self.order_verb = fields[4]
        self.quantity = fields[5]
        self.orderbook = fields[6]
        self.price = fields[7]
        self.time_in_force = fields[8]
        self.client_id = fields[9]
        self.minimum_quantity = fields[10]
        return


class ReplaceOrder(OuchMessage):
    _format = '!c L L q L'
    _ouch_type = 'U'

    def __init__(self):
        self.existing_order_token = 0
        self.replacement_order_token = 0
        self.quantity = 0
        self.price = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.existing_order_token,
                           self.replacement_order_token,
                           self.quantity,
                           self.price)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.existing_order_token = fields[1]
        self.replacement_order_token = fields[2]
        self.quantity = fields[3]
        self.price = fields[4]
        return


class CancelOrder(OuchMessage):
    _format = '!c L'
    _ouch_type = 'X'

    def __init__(self):
        self.order_token = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.order_token)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.order_token = fields[1]
        return


class SystemEvent(OuchMessage):
    _format = '!c Q c'
    _ouch_type = 'S'

    START_OF_DAY = 'S'
    END_OF_DAY = 'E'

    def __init__(self):
        self.timestamp = 0
        self.event_code = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.event_code)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.event_code = fields[2]
        return


class Accepted(OuchMessage):
    _format = '!c Q L c L c q L L L L Q Q c'
    _ouch_type = 'A'

    def __init__(self):
        self.timestamp = 0
        self.order_token = 0
        self.account_type = ''
        self.account_id = 0
        self.order_verb = ''
        self.quantity = 0
        self.orderbook = 0
        self.price = 0
        self.time_in_force = 0
        self.client_id = 0
        self.order_reference_number = 0
        self.minimum_quantity = 0
        self.order_state = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token,
                           self.account_type,
                           self.account_id,
                           self.order_verb,
                           self.quantity,
                           self.orderbook,
                           self.price,
                           self.time_in_force,
                           self.client_id,
                           self.order_reference_number,
                           self.minimum_quantity,
                           self.order_state)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2]
        self.account_type = fields[3]
        self.account_id = fields[4]
        self.order_verb = fields[5]
        self.quantity = fields[6]
        self.order_book = fields[7]
        self.price = fields[8]
        self.time_in_force = fields[9]
        self.client_id = fields[10]
        self.order_reference_number = fields[11]
        self.minimum_quantity = fields[12]
        self.order_state = fields[13]
        return


class Replaced(OuchMessage):
    _format = '!c Q L c q L L Q c L'
    _ouch_type = 'U'

    def __init__(self):
        self.timestamp = 0
        self.replacement_order_token = 0
        self.order_verb = ''
        self.quantity = 0
        self.orderbook = 0
        self.price = 0
        self.order_reference_number = 0
        self.order_state = ''
        self.previous_order_token = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.replacement_order_token,
                           self.order_verb,
                           self.quantity,
                           self.orderbook,
                           self.price,
                           self.order_reference_number,
                           self.order_state,
                           self.previous_order_token)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.replacement_order_token = fields[2]
        self.order_verb = fields[3]
        self.quantity = fields[4]
        self.orderbook = fields[5].
        self.price = fields[6]
        self.order_reference_number = fields[7]
        self.order_state = fields[8]
        self.previous_order_token = fields[9]
        return


class Canceled(OuchMessage):
    _format = '!c Q L q c'
    _ouch_type = 'C'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.quantity = 0
        self.reason = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token,
                           self.quantity,
                           self.reason)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2]
        self.quantity = fields[3]
        self.reason = fields[4]
        return


class Executed(OuchMessage):
    _format = '!c Q L L c Q L'
    _ouch_type = 'E'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.executed_quantity = 0
        self.executed_price = 0
        self.liquidity_flag = ''
        self.match_number = 0
        self.counter_party_id = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token,
                           self.executed_quantity,
                           self.executed_price,
                           self.liquidity_flag,
                           self.match_number,
                           self.counter_party_id)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2]
        self.executed_quantity = fields[3]
        self.executed_price = fields[4]
        self.liquidity_flag = fields[5]
        self.match_number = fields[6]
        self.counter_party_id = fields[7]
        return


class TradeCorrection(OuchMessage):
    _format = '!cQ14sLLcQc'
    _ouch_type = 'F'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.executed_shares = 0
        self.execution_price = 0
        self.liquidity_flag = ''
        self.match_number = 0
        self.trade_correction_reason = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14),
                           self.executed_shares,
                           self.execution_price,
                           self.liquidity_flag,
                           self.match_number,
                           self.trade_correction_reason)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        self.executed_shares = fields[3]
        self.execution_price = fields[4]
        self.liquidity_flag = fields[5]
        self.match_number = fields[6]
        self.trade_correction_reason = fields[7]
        return


class BrokenTrade(OuchMessage):
    _format = '!c Q L Q c'
    _ouch_type = 'B'

    def __init__(self):
        self.timestamp = 0
        self.order_token = 0
        self.match_number = 0
        self.reason = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token,
                           self.match_number,
                           self.reason)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2]
        self.match_number = fields[3]
        self.reason = fields[4]
        return


class Rejected(OuchMessage):
    _format = '!c Q L c'
    _ouch_type = 'J'

    def __init__(self):
        self.timestamp = 0
        self.order_token = 0
        self.reason = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token,
                           self.reason)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2]
        self.reason = fields[3]
        return


UNSEQUENCED_MESSAGES = {
    "O": EnterOrder,
    "U": ReplaceOrder,
    "X": CancelOrder,
}

SEQUENCED_MESSAGES = {
    "A": Accepted,
    "B": BrokenTrade,
    "C": Canceled,
    "E": Executed,
    "J": Rejected,
    "S": SystemEvent,
    "U": Replaced,
}

INTEGER_FIELDS = [
    "account_id",
    "client_id",
    "counter_party_id",
    "executed_price",
    "executed_quantity",
    "match_number",
    "minimum_quantity",
    "order_token"
    "order_reference_number",
    "orderbook",
    "previous_order_toke",
    "price",
    "quantity",
    "reference_price",
    "replacement_order_token",
    "time_in_force",
    "timestamp",
]


########################################################################
