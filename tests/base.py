import unittest
from rfps import soupbin


class BaseTests(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_soup_client_heartbeat(self):
        pkt = soupbin.ClientHeartbeat()
        s = pkt.encode()

        clone = soupbin.ClientHeartbeat()
        clone.decode(s)
        self.assertEqual(pkt._type, clone._type)
        return


    def test_soup_debug(self):
        pkt = soupbin.Debug()
        pkt.text = "SOUP debug text string"
        s = pkt.encode()
        clone = soupbin.Debug()
        clone.decode(s)
        self.assertEqual(pkt._type, clone._type)
        self.assertEqual(pkt.text, clone.text)
        return


    def test_soup_end_of_session(self):
        pkt = soupbin.EndOfSession()
        s = pkt.encode()
        clone = soupbin.EndOfSession()
        clone.decode(s)
        self.assertEqual(pkt._type, clone._type)
        return


    def test_soup_login_accepted(self):
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


