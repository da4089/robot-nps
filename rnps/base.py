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

import logging

from twisted.internet import reactor
from twisted.internet.protocol import connectionDone, Protocol, ClientFactory,\
    ServerFactory

import errors


# Module-local logger.
logger = logging.getLogger(__name__)


def string_to_boolean(s):
    """Convert a string to a boolean.

    Used to process arguments from Robot Framework test scripts."""

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
        """Override Twisted event callback."""
        logger.debug("%s: BaseServerSession::connectionMade()",
                     self.protocol_name)
        return Protocol.connectionMade(self)

    def connectionLost(self, reason=connectionDone):
        """Override Twisted event callback."""
        logger.debug("%s: BaseServerSession::connectionLost(): %s",
                     self.protocol_name, reason)
        return Protocol.connectionLost(self, reason)

    def dataReceived(self, data):
        """Override Twisted event callback."""

        #FIXME: could be implemented by passing a class in set_protocol()
        #FIXME: and using a standard set of functions for unpacking buffers
        #FIXME: and creating message instances.  Or a factory class.

        raise NotImplementedError("BaseServerSession::dataReceived()")

    def send_buffer(self, buf):
        logger.debug("%s: BaseServerSession::send_buffer(): %u bytes",
                     self.protocol_name, len(buf))
        self.sent += buf

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

    def receive_queue_length(self):
        return len(self.received_messages)

    def get_received_message(self):
        if len(self.received_messages) < 1:
            raise errors.ReceivedMessageQueueEmpty()
        return self.received_messages.pop(0)


class BaseServerFactory(ServerFactory):
    """A BaseServerFactory is essentially a listening socket.

    Inbound connections will create BaseServerSession instances, which can be
    then be managed via this factory."""

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

        self.endpoint.stopListening()
        self.endpoint = None
        return

    def accept_session(self, session_name):
        """Bind a queued client connection to the specified session name."""

        if len(self.new_sessions) < 1:
            raise errors.NoNewServerSessionsError()

        if session_name in self.sessions:
            raise errors.DuplicateServerSessionError(session_name)

        session = self.new_sessions.pop(0)
        self.sessions[session_name] = session
        return

    def disconnect_session(self, session_name):
        """Initiate disconnection of the specified server session."""

        session = self.sessions.get(session_name)
        if not session:
            raise errors.NoSuchServerSessionError(session_name)

        session.disconnect()
        return

    def flush_session(self, session_name):
        """Send all queued outbound messages for the specified session."""

        session = self.sessions.get(session_name)
        if not session:
            raise errors.NoSuchServerSessionError(session_name)

        session.flush()
        return

    def get_session_queue_length(self, session_name):
        """Return the number of received messages queued for the specified
        session."""

        session = self.sessions.get(session_name)
        if not session:
            raise errors.NoSuchServerSessionError(session_name)

        return session.receive_queue_length()

    def get_received_message(self, session_name):
        """Return the oldest received message queued for the specified
        session."""

        session = self.sessions.get(session_name)
        if not session:
            raise errors.NoSuchServerSessionError(session_name)

        return session.get_received_message()

    def send_message(self, session_name, message):
        """Send a message from the specified server session.

        Note that the message is queued, not sent immediately, unless the
        session is configured to automatically flush sent messages.  The queue
        can be manually flushed using 'flush_session()'."""

        session = self.sessions.get(session_name)
        if not session:
            raise errors.NoSuchServerSessionError(session_name)

        logger.debug("send_message(%s, %s)",
                     session_name,
                     message.__class__.__name__)

        if hasattr(message, "_payload"):
            message.message = message._payload.encode()

        return session.send_buffer(message.encode())

    def destroy(self):
        """Destroy this server, and any sessions it has active."""

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
    """A BaseClient instance represents, essentially, a client-side socket."""

    def __init__(self, factory, address):
        self.factory = factory
        self.address = address

        self.sent = ''
        self.receive_buffer = ''
        self.received_messages = []
        self.protocol_name = ''
        return

    def set_protocol(self, name):
        self.protocol_name = name
        return

    def dataReceived(self, data):
        """Override Twisted event callback."""

        #FIXME: could be implemented by passing a class in set_protocol()
        #FIXME: and using a standard set of functions for unpacking buffers
        #FIXME: and creating message instances.  Or a factory class.

        raise NotImplementedError("BaseClient::dataReceived()")

    def connectionMade(self):
        logger.debug("connectionMade()")
        return Protocol.connectionMade(self)

    def connectionLost(self, reason=connectionDone):
        logger.debug("connectionLost(): %s", str(reason))
        return Protocol.connectionLost(self, reason)

    def send_buffer(self, buf):
        logger.debug("send_buffer(): sending %u bytes.", len(buf))
        self.sent += buf

        if self.factory.auto_flush:
            self.flush()

        return

    def flush(self):
        logger.debug("flush(): flushing %u bytes.", len(self.sent))
        self.transport.write(self.sent)
        self.sent = ''
        return

    def disconnect(self):
        self.transport.loseConnection()
        return

    def receive_queue_length(self):
        return len(self.received_messages)

    def get_received_message(self):
        if len(self.received_messages) < 1:
            raise errors.ReceivedMessageQueueEmpty()
        return self.received_messages.pop(0)


class BaseClientFactory(ClientFactory):
    """A BaseClientFactory creates, manages and destroys a single BaseClient
    instance.

    A BaseClient instance reflects, essentially, an open socket.  The factory
    represents the supporting infrastructure for that socket or session, and
    forms a point of reference for communicating with the BaseClient itself.
    """
    def __init__(self, robot, name,
                 server_host, server_port,
                 protocol_version, client_port):
        self.robot = robot
        self.name = name
        self.host = server_host
        self.port = server_port
        self.version = protocol_version
        self.local_port = client_port

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
        return ClientFactory.startedConnecting(self, connector)

    def clientConnectionLost(self, connector, reason):
        logger.debug("%s: BaseClient::clientConnectionLost(): %s",
                     self.protocol_name, reason)
        self.session = None
        return ClientFactory.clientConnectionLost(self, connector, reason)

    def clientConnectionFailed(self, connector, reason):
        logger.debug("%s: BaseClient::clientConnectionFailed(): %s",
                     self.protocol_name, reason)
        self.session = None
        return ClientFactory.clientConnectionFailed(self, connector, reason)

    def buildProtocol(self, address):
        logger.debug("%s: BaseClient::buildProtocol(): connected.",
                     self.protocol_name)
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
    """Common functionality for all Robot Framework protocol simulator
    libraries."""

    def __init__(self):
        self.clients = {}
        self.servers = {}
        self.server_sessions = {}
        self.messages = {}
        self.protocol_name = ''
        return

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
            if server.endpoint:
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

    def create_server(self, server_name, port, version):
        """Create a server.

        The `server_name` is used to specify this server using
        other keywords.  `port` is the TCP port number on
        which this server listens for client connections.
        `version` is the protocol version to be offered.

        See also 'Destroy Server'."""

        if server_name in self.servers:
            raise errors.DuplicateServerError(server_name)

        factory = BaseServerFactory(self, server_name, port, version)
        self.servers[server_name] = factory

        logger.info("%s: new server: %s @ %u, v%u",
                    self.protocol_name, server_name, port, version)
        return

    def destroy_server(self, server_name):
        """Destroy the named server.

        `server_name` of the server to destroy, as given when it was created.

        See also 'Create Server'."""

        if not server_name in self.servers:
            raise errors.NoSuchServerError(server_name)

        factory = self.servers.pop(server_name)
        factory.destroy()
        logger.debug("destroy_server(%s)", server_name)
        return

    def server_start_listening(self, server_name):
        """Start listening for connections from clients."""

        server = self.servers.get(server_name)
        if not server:
            raise errors.NoSuchServerError(server_name)

        server.start_listening()
        return

    def server_stop_listening(self, server_name):
        """Stop listening for connections from clients."""

        server = self.servers.get(server_name)
        if not server:
            raise errors.NoSuchServerError(server_name)

        server.stopListening()
        return

    def server_has_new_session(self, server_name):
        """Returns true if an unhandled client session is queued."""

        server = self.servers.get(server_name)
        if not server:
            raise errors.NoSuchServerError(server_name)

        num_new_sessions = len(server.new_sessions)
        if not num_new_sessions:
            raise errors.NoNewServerSessionsError()

        return

    def get_new_server_session(self, server_name, session_name):
        """Get next unhandled client session."""

        session = self.servers.get(server_name)
        if not session:
            raise errors.NoSuchServerError(server_name)

        if session_name in self.server_sessions:
            raise errors.DuplicateServerSessionError(session_name)

        self.server_sessions[session_name] = session
        session.accept_session(session_name)
        return

    def disconnect_server_session(self, session_name):
        """Disconnect specified session."""

        session = self.server_sessions.get(session_name)
        if not session:
            raise errors.NoSuchServerSessionError(session_name)

        session.disconnect_session(session_name)
        logger.debug("disconnect_server_session(%s)", session_name)
        return

    def set_server_send_heartbeats(self,
                                   session_name,
                                   send_heartbeats_automatically):
        """Control whether server session sends heartbeats automatically."""

        session = self.server_sessions.get(session_name)
        if not session:
            raise errors.NoSuchServerSessionError(session_name)

        session.auto_send_heartbeats \
            = string_to_boolean(send_heartbeats_automatically)
        return

    def set_server_receive_heartbeats(self,
                                      session_name,
                                      receive_heartbeats_automatically):
        """Control whether server session receives heartbeats automatically."""

        session = self.server_sessions.get(session_name)
        if not session:
            raise errors.NoSuchServerSessionError(session_name)

        session.auto_receive_heartbeats \
            = string_to_boolean(receive_heartbeats_automatically)
        return

    def set_server_flushing(self, session_name, flush_messages_automatically):
        """Control whether session flushes outbound messages automatically."""

        session = self.server_sessions.get(session_name)
        if not session:
            raise errors.NoSuchServerSessionError(session_name)

        session.auto_flush = string_to_boolean(flush_messages_automatically)
        return

    def get_server_receive_queue_size(self, session_name):
        """Get number of queued inbound messages for server session."""

        session = self.server_sessions.get(session_name)
        if not session:
            raise errors.NoSuchServerSessionError(session_name)

        return session.get_session_queue_length(session_name)

    def server_has_received_message(self, session_name):
        """Check server session's received queue is not empty."""

        if self.get_server_receive_queue_size(session_name) == 0:
            raise errors.ReceivedMessageQueueEmpty(session_name)
        return

    def get_server_message(self, session_name, message_name):
        """Get next queued received message for session."""

        session = self.server_sessions.get(session_name)
        if not session:
            raise errors.NoSuchServerSessionError(session_name)

        if message_name in self.messages:
            raise errors.DuplicateMessageError(message_name)

        self.messages[message_name] = session.get_received_message(session_name)
        return

    def send_server_message(self, session_name, message_name):
        """Send message from the specified server session."""

        session = self.server_sessions.get(session_name)
        if not session:
            raise errors.NoSuchServerSessionError(session_name)

        msg = self.messages.get(message_name)
        if not msg:
            raise errors.NoSuchMessageError(message_name)

        logger.debug("send_server_message(%s, %s)",
                     session_name,
                     msg.__class__.__name__)
        session.send_message(session_name, msg)
        return

    def create_client(self, client_name,
                      server_host, server_port,
                      protocol_version, client_port="0"):
        """Create a client session."""

        if client_name in self.clients:
            raise errors.DuplicateClientError(client_name)

        factory = BaseClientFactory(self, client_name,
                                    server_host, server_port,
                                    protocol_version)
        self.clients[client_name] = factory
        return

    def destroy_client(self, client_name):
        """Destroy a client session."""

        if client_name not in self.clients:
            raise errors.NoSuchClientError(client_name)

        factory = self.clients.pop(client_name)
        factory.destroy()
        logger.debug("destroy_client(%s)", client_name)
        return

    def connect_client(self, client_name):
        """Initiate connection to the configured server."""

        client = self.clients.get(client_name)
        if not client:
            raise errors.NoSuchClientError(client_name)

        if client.session:
            raise errors.DuplicateClientSessionError(client_name)

        reactor.connectTCP(client.host, int(client.port), client,
                           bindAddress=("0.0.0.0", int(client.local_port)))
        return

    def disconnect_client(self, client_name):
        """Initiate disconnection from the configured server."""

        if client_name not in self.clients:
            raise errors.NoSuchClientError(client_name)

        self.clients[client_name].disconnect_session()
        return

    def set_client_send_heartbeats(self,
                                   client_name,
                                   send_heartbeats_automatically):
        """Control whether client session sends heartbeats automatically."""

        session = self.clients.get(client_name)
        if not session:
            raise errors.NoSuchClientError(client_name)

        session.auto_send_heartbeats \
            = string_to_boolean(send_heartbeats_automatically)
        return

    def set_client_receive_heartbeats(self,
                                      client_name,
                                      receive_heartbeats_automatically):
        """Control whether client session receives heartbeats automatically."""

        session = self.clients.get(client_name)
        if not session:
            raise errors.NoSuchClientError(client_name)

        session.auto_receive_heartbeats \
            = string_to_boolean(receive_heartbeats_automatically)
        return

    def set_client_flushing(self, client_name, flush_messages_automatically):
        """Control whether sent messages are immediately flushed."""
        session = self.clients.get(client_name)
        if not session:
            raise errors.NoSuchClientError(client_name)

        session.auto_flush = string_to_boolean(flush_messages_automatically)
        return

    def flush_client_send_queue(self, client_name):
        """Manually flush the outbound message queue."""

        client_session = self.clients.get(client_name)
        if not client_session:
            raise errors.NoSuchClientError(client_name)

        if not client_session.session:
            raise errors.ClientSessionNotConnectedError(client_name)

        client_session.session.flush()
        return

    def get_client_receive_queue_size(self, client_name):
        """Get number of queued messages for client session."""

        client = self.clients.get(client_name)
        if not client:
            raise errors.NoSuchClientError(client_name)

        if not client.session:
            raise errors.ClientSessionNotConnectedError(client_name)

        queue_length = client.session.receive_queue_length()
        logger.debug("get_client_receive_queue_size(%s) => %u",
                     client_name, queue_length)
        return queue_length

    def client_has_received_message(self, client_name):
        """Check whether client session has any received messages queued."""

        queue_length = self.get_client_receive_queue_size(client_name)
        logger.debug("client_has_received_message() => %s",
                     "true" if queue_length > 0 else "false")
        if queue_length < 1:
            raise errors.ReceivedMessageQueueEmpty(client_name)
        return

    def get_client_message(self, client_name, message_name):
        """Get next queued received message from client session."""

        client = self.clients.get(client_name)
        if not client:
            raise errors.NoSuchClientError(client_name)

        if not client.session:
            raise errors.ClientSessionNotConnectedError(client_name)

        if message_name in self.messages:
            raise errors.DuplicateMessageError(message_name)

        self.messages[message_name] = client.session.get_received_message()
        return

    def send_client_message(self, client_name, message_name):
        """Send a message from the named client session."""

        client = self.clients.get(client_name)
        if not client:
            raise errors.NoSuchClientError(client_name)

        msg = self.messages.get(message_name)
        if not msg:
            raise errors.NoSuchMessageError(message_name)

        if not client.session:
            raise errors.ClientSessionNotConnectedError(client_name)

        if hasattr(msg, "_payload"):
            msg.message = msg._payload.encode()

        client.session.send_buffer(msg.encode())
        return




########################################################################
