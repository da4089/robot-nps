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

import unittest
from rfps import soupbin


class SoupBinTests(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_soupbin_client_heartbeat(self):
        pkt = soupbin.ClientHeartbeat()
        s = pkt.encode()

        clone = soupbin.ClientHeartbeat()
        clone.decode(s)
        self.assertEqual(pkt._type, clone._type)
        return

    def test_soupbin_debug(self):
        pkt = soupbin.Debug()
        pkt.text = "SOUP debug text string"
        s = pkt.encode()
        clone = soupbin.Debug()
        clone.decode(s)
        self.assertEqual(pkt._type, clone._type)
        self.assertEqual(pkt.text, clone.text)
        return

    def test_soupbin_end_of_session(self):
        pkt = soupbin.EndOfSession()
        s = pkt.encode()
        clone = soupbin.EndOfSession()
        clone.decode(s)
        self.assertEqual(pkt._type, clone._type)
        return

    def test_soupbin_login_accepted(self):
        pkt = soupbin.LoginAccepted()
        pkt.session = 'SESSIONA'
        pkt.sequence_number = 42
        s = pkt.encode()

        clone = soupbin.LoginAccepted()
        clone.decode(s)
        self.assertEqual(pkt._type, clone._type)
        self.assertEqual(pkt.session, clone.session)
        self.assertEqual(pkt.sequence_number, clone.sequence_number)
        return


    def test_soupbin_login_rejected(self):
        pkt = soupbin.LoginRejected()
        pkt.reject_reason_code = soupbin.LoginRejected.NOT_AUTHORIZED
        s = pkt.encode()

        clone = soupbin.LoginRejected()
        clone.decode(s)
        self.assertEqual(pkt.reject_reason_code, clone.reject_reason_code)
        return

    def test_soupbin_login_request(self):
        pkt = soupbin.LoginRequest()
        pkt.username = "USER"
        pkt.password = "PASSWORD"
        pkt.requested_session = "SESSIONA"
        pkt.requested_sequence_number = 42
        s = pkt.encode()

        clone = soupbin.LoginRequest()
        clone.decode(s)
        self.assertEqual(pkt.username, clone.username)
        self.assertEqual(pkt.password, clone.password)
        self.assertEqual(pkt.requested_session, clone.requested_session)
        self.assertEqual(pkt.requested_sequence_number, clone.requested_sequence_number)
        return

    def test_soupbin_logout_request(self):
        pkt = soupbin.LogoutRequest()
        s = pkt.encode()

        clone = soupbin.LogoutRequest()
        clone.decode(s)
        self.assertEqual(pkt._type, clone._type)
        return

    def test_soupbin_sequenced_data(self):
        pkt = soupbin.SequencedData()
        pkt.message = "encapsulated message bytes"
        s = pkt.encode()

        clone = soupbin.SequencedData()
        clone.decode(s)
        self.assertEqual(pkt.message, clone.message)
        return

    def test_soupbin_server_heartbeat(self):
        pkt = soupbin.ServerHeartbeat()
        s = pkt.encode()

        clone = soupbin.ServerHeartbeat()
        clone.decode(s)
        self.assertEqual(pkt._type, clone._type)
        return

    def test_soupbin_unsequenced_data(self):
        pkt = soupbin.UnsequencedData()
        pkt.message = "encapsulated message bytes"
        s = pkt.encode()

        clone = soupbin.UnsequencedData()
        clone.decode(s)
        self.assertEqual(pkt.message, clone.message)
        return
