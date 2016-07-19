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

import exceptions


class BadBooleanError(exceptions.ValueError):
    """Cannot convert supplied value to boolean."""
    pass


class BadUTCDateOnlyError(exceptions.ValueError):
    """Cannot convert supplied value to UTC Date Only."""
    pass


class BadUTCTimestampError(exceptions.ValueError):
    """Cannot convert supplied value to UTC Timestamp."""
    pass


class BadUTCTimeOnlyError(exceptions.ValueError):
    """Cannot convert supplied value to UTC Time Only."""
    pass


class BadFieldNameError(exceptions.NameError):
    """No field of this name in the specified message."""
    pass


class BadLocalMarketDateError(exceptions.ValueError):
    """Cannot convert supplied value to local market date."""
    pass


class BadMessageTypeError(exceptions.ValueError):
    """The supplied message type is not recognised."""
    pass


class ClientSessionNotConnectedError(exceptions.Exception):
    """The specified client session is not connected."""
    pass


class DuplicateClientError(exceptions.LookupError):
    """A client with this name already exists."""
    pass


class DuplicateMessageError(exceptions.LookupError):
    """A message with this name already exists."""
    pass


class DuplicateServerError(exceptions.LookupError):
    """A server with this name already exists."""
    pass


class DuplicateServerSessionError(exceptions.LookupError):
    """A server session with this name already exists."""
    pass


class NoNewServerSessionsError(exceptions.LookupError):
    """No accepted but unhandled server sessions exists."""
    pass


class NoSuchClientError(exceptions.LookupError):
    """No client with this name exists."""
    pass


class NoSuchMessageError(exceptions.LookupError):
    """No message with this name exists."""
    pass


class NoSuchServerError(exceptions.LookupError):
    """No server with this name exists."""
    pass


class NoSuchServerSessionError(exceptions.LookupError):
    """No server session with this name exists."""
    pass


class NotAnOuchMessageError(exceptions.ValueError):
    """No OUCH payload found in carrier protocol message."""
    pass


class ReceivedMessageQueueEmpty(exceptions.EOFError):
    """Specified message queue is empty."""
    pass


########################################################################
