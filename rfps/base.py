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

import logging
import os
import socket
import struct
import time

from twisted.internet import reactor
from twisted.internet.error import ConnectionDone
from twisted.internet.protocol import Protocol, ClientFactory, ServerFactory
from twisted.web.resource import Resource
from twisted.web.server import Site

import errors


# Module-local logger.
logger = logging.getLogger(__name__)


def string_to_boolean(s):
    s = s.strip().lower()
    if s in ('t', 'y', '1', 'on', 'yes', 'true'):
        return True

    elif s in ('f', 'n', '0', 'off', 'no', 'false'):
        return False

    raise errors.BadBooleanError(s)


class BaseServerSession(Protocol):
    def __init__(self, factory, address):
        self.factory = factory
        self.address = address
        self.sent = ''
        self.receive_buffer = ''
        self.received_messages = []
        self.protocol_name = ''
        return

    def set_protocol(self, protocol_name):
        self.protocol_name = protocol_name
        logger.info("New %s server session: %s @ %s",
                    self.protocol_name, self.factory.name, str(self.address))
        return

    def connectionMade(self):
        logger.debug("%s: BaseServerSession::connectionMade()",
                     self.protocol_name)
        return Protocol.connectionMade(self)

    def connectionLost(self, reason):
        logger.debug("%s: BaseServerSession::connectionLost(): %s",
                     self.protocol_name, reason)
        return Protocol.connectionLost(self, reason)

    def dataReceived(self, data):
        logger.debug("%s: BaseServerSession::dataReceived(): %u bytes",
                     self.protocol_name, len(data))
        self.receive_buffer += data

        while len(self.receive_buffer) > 0:
            #FIXME: call framing protocol module to try to get message.
            break

        return

    def sendBuffer(self, buffer):
        logger.debug("%s: BaseServerSession::sendBuffer(): %u bytes",
                     self.protocol_name, len(buffer))
        self.sent + buffer

        if self.factory.auto_flush:
            self.flush()
        return

    def flush(self):
        logger.debug("%s: BaseServerSession:flush(): flushing %u bytes.",
                     self.protocol_name, len(self.sent))
        self.transport.write(self.sent)
        self.sent = ''
        return

    def disconnect(self):
        logger.debug("%s: BaseServerSession::disconnect()",
                     self.protocol_name)
        self.transport.loseConnection()
        return

    def receive_queue_size(self):
        return len(self.received_messages)

    def get_received_message(self):
        if len(self.received_messages) < 1:
            raise errors.ReceivedMessageQueueEmpty()
        return self.received_messages.pop(0)


class BaseServerFactory(ServerFactory):
    def __init__(self, robot, name, port, version):
        self.robot = robot
        self.name = name
        self.port = port
        self.version = version
        self.protocol_name = ''

        self.auto_flush = True
        self.auto_send_heartbeats = True
        self.auto_receive_heartbeats = True
        self.next_session_id = 1

        self.endpoint = None
        self.new_sessions = []
        self.sessions = {}
        return

    def set_protocol(self, name, protocol):
        self.protocol_name = name
        self.protocol = protocol
        return

    def buildProtocol(self, address):
        logger.debug("%s: BaseServerFactory(): connected %s",
                     self.protocol_name, address)
        session = self.protocol(self, address)
        self.new_sessions.append(session)
        return session

    def start_listening(self):
        self.endpoint = reactor.listenTCP(int(self.port), self)
        logger.info("%s: BaseServerFactory::start_listening()",
                    self.protocol_name)
        return

    def stop_listening(self):
        if not self.endpoint:
            logger.warning("%s: BaseServerFactory::stop_listening(): "
                           "No endpoint for factory",
                           self.protocol_name)
            return

        self.endpoint.stop_listening()
        self.endpoint = None
        return

    def accept_session(self, name):
        if len(self.new_sessions) < 1:
            raise errors.NoNewServerSessionsError()

        if name in self.sessions:
            raise errors.DuplicateServerSessionError(name)

        session = self.new_sessions.pop(0)
        self.sessions[name] = session
        return

    def disconnect_session(self, name):
        session = self.sessions.get(name)
        if not session:
            raise errors.NoSuchServerSessionError(name)

        session.disconnect()
        return

    def flush_session(self, name):
        session = self.sessions.get(name)
        if not session:
            raise errors.NoSuchServerSessionError(name)

        session.flush()
        return

    def get_session_queue_length(self, name):
        session = self.sessions.get(name)
        if not session:
            raise errors.NoSuchServerSessionError(name)

        return len(session.received_messages)

    def get_received_message(self, session_name):
        session = self.sessions.get(session_name)
        if not session:
            raise errors.NoSuchServerSessionError(session_name)

        return session.get_received_message()

    def send_message(self, session_name, message):
        session = self.sessions.get(session_name)
        if not session:
            raise errors.NoSuchServerSessionError(session_name)

        return session.send_buffer(message.encode())

    def destroy(self):
        if self.endpoint:
            self.stop_listening()

        for name, session in self.sessions.items():
            #FIXME
            pass

        for session in self.new_sessions:
            #FIXME
            pass

        return


class BaseClient(Protocol):
    def __init__(self, factory, address):
        self.factory = factory
        self.sent = ''
        self.receive_buffer = ''
        self.received_messages = []
        self.protocol_name = ''
        self.protocol = None
        return

    def set_protocol(self, name, protocol):
        self.protocol_name = name
        self.protocol = protocol
        return

    def data_received(self, data):
        logger.debug("%s: BaseClient::dataReceived(): %u bytes",
                     self.protocol_name, len(data))
        self.receive_buffer += data

        while len(self.receive_buffer) > 0:
            # FIXME: plugin application framing protocol here!
            pass

        return

    def connectionMade(self):
        logger.debug("%s: BaseClient::connectionMade()", self.protocol_name)
        return Protocol.connectionMade(self)

    def connectionLost(self, reason=ConnectionDone):
        logger.debug("%s: BaseClient::connectionLost(): %s",
                     self.protocol_name, str(reason))
        return Protocol.connectionLost(reason)

    def send_buffer(self, buf):
        logger.debug("%s: BaseClient::send_buffer(): sending %u bytes.",
                     self.protocol_name, len(buf))
        self.sent += buf

        if self.factory.auto_flush:
            self.flush()

        return

    def flush(self):
        logger.debug("%s: BaseClient::flush(): flushing %u bytes.",
                     self.protocol_name, len(self.sent))
        self.transport.write(self.sent)
        self.sent = ''
        return

    def disconnect(self):
        self.transport.loseConnection()
        return

    def receive_queue_size(self):
        return len(self.received_messages)

    def get_received_message(self):
        if len(self.received_messages) < 1:
            raise errors.ReceivedMessageQueueEmpty()
        return self.received_messages.pop(0)



class BaseClientFactory(ClientFactory):
    def __init__(self, robot, name, host, port, version):
        self.robot = robot
        self.name = name
        self.host = host
        self.port = port
        self.version = version
        self.protocol_name = ''
        self.protocol = None

        self.auto_flush = True
        self.auto_send_heartbeats = True
        self.auto_receive_heartbeats = True

        self.session = None
        return

    def set_protocol(self, name, protocol):
        self.protocol_name = name
        self.protocol = protocol
        return

    def startedConnecting(self, connector):
        logger.debug("%s: BaseClient::startedConnecting()", self.protocol_name)
        return ClientFactory.startedConnecting(connector)

    def clientConnectionLost(self, connector, reason):
        logger.debug("%s: BaseClient::clientConnectionLost(): %s",
                     self.protocol_name, reason)
        self.session = None
        return ClientFactory.clientConnectionLost(connector, reason)

    def clientConnectionFailed(self, connector, reason):
        logger.debug("%s: BaseClient::clientConnectionFailed(): %s",
                     self.protocol_name, reason)
        self.session = None
        return ClientFactory.clientConnectionFailed(connector, reason)

    def buildProtocol(self, address):
        logger.debug("%s: BaseClient::buildProtocol(): connected.")
        self.session = self.protocol(self, address)
        return self.session

    def disconnect_session(self):
        if not self.session:
            logger.warning("%s: BaseClient::disconnect_session(): "
                           "No session for factory.",
                           self.protocol_name)
            return

        self.session.disconnect()
        self.session = None
        return

    def destroy(self):
        if self.session:
            self.disconnect_session()
        return


class BaseRobot(object):
    def __init__(self):
        self.clients = {}
        self.servers = {}
        self.server_sessions = {}
        self.messages = {}
        self.protocol_name = ''
        return

    def ping(self):
        return True

    def reset(self):
        """Delete all defined messages, clients and servers.

        This command basically resets the remote simulator to
        its initial state.  All messages, clients and servers
        created since startup (or the last call to reset) are
        deleted.

        See also the 'Destroy All Messages' keyword."""

        # Clean up clients.
        for name, client in self.clients.items():
            if client.session:
                client.session.disconnect()
            del self.clients[name]

        # Clean up server sessions.
        for session, server in self.server_sessions.items():
            server.disconnect_session(session)
            del self.server_sessions[session]

        # Clean up servers.
        for name, server in self.servers.items():
            if server.endpoint():
                server.destroy()
            del self.servers[name]

        # Clean up messages.
        self.destroy_all_messages()
        return

    def destroy_all_messages(self):
        """Destroy all defined messages.

        This keyword will remove all messages defined for
        the remote simulator, but leave client and server
        sessions intact.

        See all the 'Reset' keyword."""
        self.messages = {}
        return

    def create_server(self, name, port, version):
        """Create a server.

        The `name` is used to specify this server using
        other keywords.  `port` is the TCP port number on
        which this server listens for client connections.
        `version` is the protocol version to be offered.

        See also 'Destroy Server'."""

        if name in self.servers:
            raise errors.DuplicateServerError(name)

        factory = BaseServerFactory(self, name, port, version)
        self.servers[name] = factory

        logger.info("%s: new server: %s @ %u, v%u",
                    self.protocol_name, name, port, version)
        return

    def destroy_server(self, name):
        """Destroy the named server.

        `name` of the server to destroy, as given when it
        was created.

        See also 'Create Server'."""

        if not name in self.servers:
            raise errors.NoSuchServerError(name)

        factory = self.servers.pop(name)
        factory.destroy()
        return


########################################################################
