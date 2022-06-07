import unittest

from keywey.language import _load_stopwords, _load_case


class TestLoadFunctions(unittest.TestCase):

    def test_load_stopwords_en_hi(self):
        for lang, num_stopwords in zip(['en', 'hi'], [179, 264]):
            with self.subTest(lang=lang, num_stopwords=num_stopwords):
                stopwords = _load_stopwords(lang=lang)
                self.assertEqual(len(stopwords), num_stopwords)

    def test_load_case_en_hi(self):
        self.assertEqual(_load_case(lang='en'), 'exists')
        self.assertEqual(_load_case(lang='hi'), 'notdefined')
