########################################################################
# robot-fps, Financial Protocol Simulator for Robot Framework
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

from base import *
import soupbin
import ouch4

# Module-local logger.
logger = logging.getLogger(__name__)


########################################################################

class OuchServerSession(BaseServerSession):
    def __init__(self, factory, address):
        BaseServerSession.__init__(self, factory, address)
        self.set_protocol("OUCH")
        return

    def dataReceived(self, data):
        """Handle a received packet.

        Override of Twisted method from base class."""

        self.receive_buffer += data

        while len(self.receive_buffer) > 0:
            if not soupbin.has_complete_message(self.receive_buffer):
                return

            msg, self.receive_buffer = soupbin.get_message(self.receive_buffer)

            if msg.get_type() == 'R' and self.factory.auto_receive_heartbeats:
                logger.info("OUCH: Server session [%s]: consumed heartbeat",
                            self.factory.name)
                return

            self.received_messages.append(msg)
            logger.info("%s: server queuing %s",
                        self.factory.name, msg.get_type())

        return


class OuchServerFactory(BaseServerFactory):
    def __init__(self, robot, name, port, version):
        BaseServerFactory.__init__(self, robot, name, port, version)
        self.set_protocol("OUCH", OuchServerSession)
        return


class OuchClient(BaseClient):
    def __init__(self, factory, address):
        self.set_protocol("OUCH")
        BaseClient.__init__(self, factory, address)
        return

    def dataReceived(self, data):
        """Handle a received packet.

        Override of Twisted method from base class."""

        self.receive_buffer += data

        while len(self.receive_buffer) > 0:
            if not soupbin.has_complete_message(self.receive_buffer):
                return

            msg, self.receive_buffer = soupbin.get_message(self.receive_buffer)
            if not msg:
                return

            if msg.get_type() == 'H' and self.factory.auto_receive_heartbeats:
                logger.info("OUCH: Session [%s]: consumed heartbeat",
                            self.factory.name)
                return

            self.received_messages.append(msg)
            logger.info("%s: client queuing %s",
                        self.factory.name, msg.get_type())

        return


class OuchClientFactory(BaseClientFactory):
    def __init__(self, robot, name, host, port, version):
        BaseClientFactory.__init__(self, robot, name, host, port, version)
        self.set_protocol("OUCH", OuchClient)
        return


class OuchRobot(BaseRobot):
    def __init__(self):
        self.protocol_name = "OUCH"
        BaseRobot.__init__(self)
        return

    def create_client(self, client_name, host, port, version):
        """Create an OUCH client session."""

        if client_name in self.clients:
            raise errors.DuplicateClientError(client_name)

        client = OuchClientFactory(self, client_name, host, port, version)
        self.clients[client_name] = client
        logger.info("Created OUCH client: %s @ %s:%s v%s",
                    client_name, host, port, version)
        return

    def create_server(self, server_name, port, version):
        """Create an OUCH server."""

        if server_name in self.servers:
            raise errors.DuplicateServerError(server_name)

        server = OuchServerFactory(self, server_name, port, version)
        self.servers[server_name] = server
        logger.info("Created OUCH server: %s @ port %s v%s",
                    server_name, port, version)
        return

    def create_soup_message(self, name, soup_type):
        if name in self.messages:
            raise errors.DuplicateMessageError(name)

        constructor = soupbin.Messages.get(soup_type)
        if not constructor:
            raise errors.BadMessageTypeError(soup_type)

        self.messages[name] = constructor()
        return

    def destroy_soup_message(self, name):
        if name not in self.messages:
            raise errors.NoSuchMessageError(name)

        del self.messages[name]
        return

    def get_soup_type(self, message_name):
        """Get the SOUP type of the specified message."""

        msg = self.messages.get(message_name)
        if not msg:
            raise errors.NoSuchMessageError(message_name)

        return msg.get_type()

    def set_soup_field(self, name, field, value):
        """Set a field in the specified SOUP message."""

        msg = self.messages.get(name)
        if not msg:
            raise errors.NoSuchMessageError(name)

        if not hasattr(msg, field) or field[0:1] == "_":
            raise errors.BadFieldNameError(field)

        setattr(msg, field, value)
        return

    def get_soup_field(self, message_name, field_name):
        """Get the value of a field in a SOUP message."""

        msg = self.messages.get(message_name)
        if not msg:
            raise errors.NoSuchMessageError(message_name)

        if field_name[0:1] == "_" or not hasattr(msg, field_name):
            raise errors.BadFieldNameError(field_name)

        return getattr(msg, field_name)

    def set_ouch_type(self, message_name, ouch_type):
        """Set the OUCH message type for this message."""

        msg = self.messages.get(message_name)
        if not msg:
            raise errors.NoSuchMessageError(message_name)

        constructor = None
        if msg.get_type() == 'U':
            constructor = ouch4.UNSEQUENCED_MESSAGES.get(ouch_type)
        elif msg.get_type() == 'S':
            constructor = ouch4.SEQUENCED_MESSAGES.get(ouch_type)
        else:
            raise errors.BadMessageTypeError("SOUP message must be U or S, "
                                             "not %c" % msg.get_type())
        if not constructor:
            raise errors.BadMessageTypeError(ouch_type)

        msg._payload = constructor()
        return

    def get_ouch_type(self, message_name):
        """Get the OUCH message type for this message."""

        msg = self.messages.get(message_name)
        if not msg:
            raise errors.NoSuchMessageError(message_name)

        if not hasattr(msg, "_payload"):
            raise errors.NotAnOuchMessageError(message_name)

        #FIXME: accessors
        return msg._payload._ouch_type

    def get_ouch_field(self, message_name, field_name):
        """Get an OUCH message field from this message."""

        msg = self.messages.get(message_name)
        if not msg:
            raise errors.NoSuchMessageError(message_name)

        if not hasattr(msg, "_payload"):
            raise errors.NotAnOuchMessageError(message_name)

        if field_name[0:1] == "_" or not hasattr(msg._payload, field_name):
            raise errors.BadFieldNameError(field_name)

        return getattr(msg._payload, field_name)

    def set_ouch_field(self, message_name, field_name, value):
        """Set an OUCH message field value in this message."""

        msg = self.messages.get(message_name)
        if not msg:
            raise errors.NoSuchMessageError(message_name)

        if not hasattr(msg, "_payload"):
            raise errors.NotAnOuchMessageError(message_name)

        if field_name[0:1] == "_" or not hasattr(msg._payload, field_name):
            raise errors.BadFieldNameError(field_name)

        if field_name in ouch4.INTEGER_FIELDS:
            value = int(value)

        setattr(msg._payload, field_name, value)
        return


########################################################################
