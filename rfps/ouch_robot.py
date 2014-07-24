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


class OuchServerSession(BaseServerSession):
    def __init__(self, factory, address):
        BaseServerSession.__init__(self, factory, address)
        self.set_protocol("OUCH")
        return

    def dataReceived(self, data):
        #FIXME
        pass


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
        #FIXME
        pass



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

