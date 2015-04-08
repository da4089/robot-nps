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

# Implements ASX OUCH as at 2015/02/25.
#
# ASX OUCH is implemented by NASDAQ OMX's Genium INET platform, as
# deployed for ASX.  It's based on NASDAQ's OUCH4, but has a bunch of
# extra fields.
#
# Source documents:
# - ASX Trade OUCH v1.0 (document #036435).
# - ASX OUCH Message Specification, v2.0, 2 September 2013.
# - ASX Trade Q2 2015 Release (SR8) Appendices to ASX Notice.

########################################################################

import struct
import errors

from ouch4 import get_message, OuchMessage


########################################################################

class EnterOrder(OuchMessage):
    #_format = '!c 14s L c Q L B B 10s 15s 32s c L c c 4s 10s 20s 8s c Q'
    _format = '!c14scL8sLL4scccLcc'
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
        return

    def encode(self):
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
                           self.short_sell_quantity)
                           
)

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
        return


class ReplaceOrder(OuchMessage):
    _format = '!c14s14sLLLccL'
    _ouch_type = 'U'

    def __init__(self):
        self.existing_order_token = ''
        self.replacement_order_token = ''
        self.shares = 0
        self.price = 0
        self.time_in_force = 0
        self.display = ''
        self.intermarket_sweep_eligibility = ''
        self.minimum_quantity = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.existing_order_token.ljust(14),
                           self.replacement_order_token.ljust(14),
                           self.shares,
                           self.price,
                           self.time_in_force,
                           self.display,
                           self.intermarket_sweep_eligibility,
                           self.minimum_quantity)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.existing_order_token = fields[1].strip()
        self.replacement_order_token = fields[2].strip()
        self.shares = fields[3]
        self.price = fields[4]
        self.time_in_force = fields[5]
        self.display = fields[6]
        self.intermarket_sweep_eligibility = fields[7]
        self.minimum_quantity = fields[8]
        return


class CancelOrder(OuchMessage):
    _format = '!c14sL'
    _ouch_type = 'X'

    def __init__(self):
        self.order_token = ''
        self.shares = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.order_token.ljust(14),
                           self.shares)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.order_token = fields[1].strip()
        self.shares = fields[2]
        return


class ModifyOrder(OuchMessage):
    _format = '!c14scL'
    _ouch_type = 'M'

    def __init__(self):
        self.order_token = ''
        self.buy_sell_indicator = ''
        self.shares = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.order_token.ljust(14),
                           self.buy_sell_indicator,
                           self.shares)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.order_token = fields[1].strip()
        self.buy_sell_indicator = fields[2]
        self.shares = fields[3]
        return


class SystemEvent(OuchMessage):
    _format = '!cQc'
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
    _format = '!cQ14scL8sLL4scQccLccc'
    _ouch_type = 'A'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.buy_sell_indicator = ''
        self.shares = 0
        self.stock = ''
        self.price = 0
        self.time_in_force = 0
        self.firm = ''
        self.display = ''
        self.order_reference_number = 0
        self.capacity = ''
        self.intermarket_sweep_eligibility = ''
        self.minimum_quantity = 0
        self.cross_type = ''
        self.order_state = ''
        self.bbo_weight_indicator = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14),
                           self.buy_sell_indicator,
                           self.shares,
                           self.stock.ljust(8),
                           self.price,
                           self.time_in_force,
                           self.firm.ljust(4),
                           self.display,
                           self.order_reference_number,
                           self.capacity,
                           self.intermarket_sweep_eligibility,
                           self.minimum_quantity,
                           self.cross_type,
                           self.order_state,
                           self.bbo_weight_indicator)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        self.buy_sell_indicator = fields[3]
        self.shares = fields[4]
        self.stock = fields[5].strip()
        self.price = fields[6]
        self.time_in_force = fields[7]
        self.firm = fields[8].strip()
        self.display = fields[9]
        self.order_reference_number = fields[10]
        self.capacity = fields[11]
        self.intermarket_sweep_eligibility = fields[12]
        self.minimum_quantity = fields[13]
        self.cross_type = fields[14]
        self.order_state = fields[15]
        self.bbo_weight_indicator = fields[16]
        return
        

class Replaced(OuchMessage):
    _format = '!cQ14scL8sLL4scQccLcc14sc'
    _ouch_type = 'U'

    def __init__(self):
        self.timestamp = 0
        self.replacement_order_token = ''
        self.buy_sell_indicator = ''
        self.shares = 0
        self.stock = ''
        self.price = 0
        self.time_in_force = 0
        self.firm = ''
        self.display = ''
        self.order_reference_number = 0
        self.capacity = ''
        self.intermarket_sweep_eligibility = ''
        self.minimum_quantity = 0
        self.cross_type = ''
        self.order_state = ''
        self.previous_order_token = ''
        self.bbo_weight_indicator = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.replacement_order_token.ljust(14),
                           self.buy_sell_indicator,
                           self.shares,
                           self.stock.ljust(8),
                           self.price,
                           self.time_in_force,
                           self.firm.ljust(4),
                           self.display,
                           self.order_reference_number,
                           self.capacity,
                           self.intermarket_sweep_eligibility,
                           self.minimum_quantity,
                           self.cross_type,
                           self.order_state,
                           self.previous_order_token.ljust(14),
                           self.bbo_weight_indicator)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.replacement_order_token = fields[2].strip()
        self.buy_sell_indicator = fields[3]
        self.shares = fields[4]
        self.stock = fields[5].strip()
        self.price = fields[6]
        self.time_in_force = fields[7]
        self.firm = fields[8].strip()
        self.display = fields[9]
        self.order_reference_number = fields[10]
        self.capacity = fields[11]
        self.intermarket_sweep_eligibility = fields[12]
        self.minimum_quantity = fields[13]
        self.cross_type = fields[14]
        self.order_state = fields[15]
        self.previous_order_token = fields[16].strip()
        self.bbo_weight_indicator = fields[17]
        return


class Canceled(OuchMessage):
    _format = '!cQ14sLc'
    _ouch_type = 'C'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.decrement_shares = 0
        self.reason = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14),
                           self.decrement_shares,
                           self.reason)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        self.decrement_shares = fields[3]
        self.reason = fields[4]
        return


class AIQCanceled(OuchMessage):
    _format = '!cQ14sLcLLc'
    _ouch_type = 'D'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.decrement_shares = 0
        self.reason = ''
        self.quantity_prevented_from_trading = 0
        self.execution_price = 0
        self.liquidity_flag = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14),
                           self.decrement_shares,
                           self.reason,
                           self.quantity_prevented_from_trading,
                           self.execution_price,
                           self.liquidity_flag)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        self.decrement_shares = fields[3]
        self.reason = fields[4]
        self.quantity_prevented_from_trading = fields[5]
        self.execution_price = fields[6]
        self.liquidity_flag = fields[7]
        return


class Executed(OuchMessage):
    _format = '!cQ14sLLcQ'
    _ouch_type = 'E'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.executed_shares = 0
        self.execution_price = 0
        self.liquidity_flag = ''
        self.match_number = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14),
                           self.executed_shares,
                           self.execution_price,
                           self.liquidity_flag,
                           self.match_number)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        self.executed_shares = fields[3]
        self.execution_price = fields[4]
        self.liquidity_flag = fields[5]
        self.match_number = fields[6]
        return
    

class BrokenTrade(OuchMessage):
    _format = '!cQ14sQc'
    _ouch_type = 'B'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.match_number = 0
        self.reason = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14),
                           self.match_number,
                           self.reason)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        self.match_number = fields[3]
        self.reason = fields[4]
        return


class PriceCorrection(OuchMessage):
    _format = '!cQ14sQLc'
    _ouch_type = 'K'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.match_number = 0
        self.new_execution_price = 0
        self.reason = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14),
                           self.match_number,
                           self.new_execution_price,
                           self.reason)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        self.match_number = fields[3]
        self.new_execution_price = fields[4]
        self.reason = fields[5]
        return


class Rejected(OuchMessage):
    _format = '!cQ14sc'
    _ouch_type = 'J'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.reason = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14),
                           self.reason)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        self.reason = fields[3]
        return


class CancelPending(OuchMessage):
    _format = '!cQ14s'
    _ouch_type = 'P'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14))

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        return


class CancelReject(OuchMessage):
    _format = '!cQ14s'
    _ouch_type = 'I'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14))

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        return


class OrderPriorityUpdate(OuchMessage):
    _format = 'cQ14sLcQ'
    _ouch_type = 'T'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.price = 0
        self.display = ''
        self.order_reference_number = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14),
                           self.price,
                           self.display,
                           self.order_reference_number)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        self.price = fields[3]
        self.display = fields[4]
        self.order_reference_number = fields[5]
        return


class OrderModified(OuchMessage):
    _format = '!cQ14scL'
    _ouch_type = 'M'

    def __init__(self):
        self.timestamp = 0
        self.order_token = ''
        self.buy_sell_indicator = ''
        self.shares = 0
        return

    def encode(self):
        return struct.pack(self._format,
                           self._ouch_type,
                           self.timestamp,
                           self.order_token.ljust(14),
                           self.buy_sell_indicator,
                           self.shares)

    def decode(self, buf):
        fields = struct.unpack(self._format, buf)
        assert fields[0] == self._ouch_type
        self.timestamp = fields[1]
        self.order_token = fields[2].strip()
        self.buy_sell_indicator = fields[3]
        self.shares = fields[4]
        return


UNSEQUENCED_MESSAGES = {
    "M": ModifyOrder,
    "O": EnterOrder,
    "U": ReplaceOrder,
    "X": CancelOrder,
}

SEQUENCED_MESSAGES = {
    "A": Accepted,
    "B": BrokenTrade,
    "C": Canceled,
    "D": AIQCanceled,
    "E": Executed,
    "I": CancelReject,
    "J": Rejected,
    "K": PriceCorrection,
    "M": OrderModified,
    "P": CancelPending,
    "S": SystemEvent,
    "T": OrderPriorityUpdate,
    "U": Replaced,
}

INTEGER_FIELDS = [
    "decrement_shares",
    "executed_shares",
    "execution_price",
    "match_number",
    "minimum_quantity",
    "new_execution_price",
    "order_reference_number",
    "price",
    "quantity_prevented_from_trading",
    "shares",
    "time_in_force",
    "timestamp",
]


########################################################################
