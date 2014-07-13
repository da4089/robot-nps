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
from rfps import soup


class SoupTests(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_soup_client_heartbeat(self):
        pkt = soup.ClientHeartbeat()
        s = pkt.encode()

        clone = soup.ClientHeartbeat()
        clone.decode(s)
        self.assertEqual(pkt._type, clone._type)
        return

    def test_soup_debug(self):
        pkt = soup.Debug()
        pkt.text = "Debug text goes here"
        s = pkt.encode()

        clone = soup.Debug()
        clone.decode(s)
        self.assertEqual(pkt.text, clone.text)
        return

    def test_soup_login_accepted(self):
        pkt = soup.LoginAccepted()
        pkt.session = "SESSIONA"
        pkt.sequence_number = 42
        s = pkt.encode()

        clone = soup.LoginAccepted()
        clone.decode(s)
        self.assertEqual(pkt.session, clone.session)
        self.assertEqual(pkt.sequence_number, clone.sequence_number)
        return

    def test_soup_login_rejected(self):
        pkt = soup.LoginRejected()
        pkt.reject_reason_code = soup.LoginRejected.NOT_AUTHORIZED
        s = pkt.encode()

        clone = soup.LoginRejected()
        clone.decode(s)
        self.assertEqual(pkt.reject_reason_code, clone.reject_reason_code)
        return

    def test_soup_login_request(self):
        pkt = soup.LoginRequest()
        pkt.username = "USER"
        pkt.password = "PASSWORD"
        pkt.requested_session = "SESSIONA"
        pkt.requested_sequence_number = 42
        s = pkt.encode()

        clone = soup.LoginRequest()
        clone.decode(s)
        self.assertEqual(pkt.username, clone.username)
        self.assertEqual(pkt.password, clone.password)
        self.assertEqual(pkt.requested_session, clone.requested_session)
        self.assertEqual(pkt.requested_sequence_number, clone.requested_sequence_number)
        return

    def test_soup_logout_request(self):
        pkt = soup.LogoutRequest()
        s = pkt.encode()

        clone = soup.LogoutRequest()
        clone.decode(s)
        self.assertEqual(pkt._type, clone._type)
        return

    def test_soup_sequenced_data(self):
        pkt = soup.SequencedData()
        pkt.message = "encapsulated message bytes"
        s = pkt.encode()

        clone = soup.SequencedData()
        clone.decode(s)
        self.assertEqual(pkt.message, clone.message)
        return

    def test_soup_server_heartbeat(self):
        pkt = soup.ServerHeartbeat()
        s = pkt.encode()

        clone = soup.ServerHeartbeat()
        clone.decode(s)
        self.assertEqual(pkt._type, clone._type)
        return

    def test_soup_unsequenced_data(self):
        pkt = soup.UnsequencedData()
        pkt.message = "encapsulated message bytes"
        s = pkt.encode()

        clone = soup.UnsequencedData()
        clone.decode(s)
        self.assertEqual(pkt.message, clone.message)
        return



