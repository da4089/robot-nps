import unittest
from rfps import soup


class BaseTests(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_soup_debug(self):
        debug = soup.Debug()
        debug.text = "SOUP debug text string"
        s = debug.encode()
        clone = soup.Debug()
        clone.decode(s)
        self.assertEqual(debug.text, clone.text)

