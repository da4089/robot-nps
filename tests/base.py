import unittest
from rfps import soupbin


class BaseTests(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_soup_debug(self):
        debug = soupbin.Debug()
        debug.text = "SOUP debug text string"
        s = debug.encode()
        clone = soupbin.Debug()
        clone.decode(s)
        self.assertEqual(debug.text, clone.text)

