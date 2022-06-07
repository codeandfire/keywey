import unittest

from keywey.keywey_core import Case, Stopwords


class TestCase(unittest.TestCase):

    def test_case_repr_str(self):
        for case_ in ['exists', 'Exists']:
            with self.subTest(case=case_):
                self.assertEqual(repr(Case(case_)), "Case('exists')")
                self.assertEqual(str(Case(case_)), "exists")

        for case_ in ['notdefined', 'NotDefined', 'Notdefined']:
            with self.subTest(case=case_):
                self.assertEqual(repr(Case(case_)), "Case('notdefined')")
                self.assertEqual(str(Case(case_)), "notdefined")

    def test_case_comparison(self):
        self.assertEqual(Case('exists'), Case('Exists'))
        self.assertEqual(Case('NotDefined'), Case('notdefined'))
        self.assertNotEqual(Case('exists'), Case('notdefined'))

        with self.assertRaisesRegex(
                TypeError,
                "operation not supported between instances of 'Case' and 'Case'"):
            Case('exists') > Case('notdefined')

    def test_case_invalid(self):
        with self.assertRaisesRegex(ValueError, "unknown case value 'foobar'"):
            Case("foobar")


class TestStopwords(unittest.TestCase):

    def test_stopwords_repr_str(self):
        stopwords = Stopwords(["a", "an", "and", "the"])
        self.assertEqual(repr(stopwords), str(stopwords))
        self.assertEqual(repr(stopwords), "Stopwords(['a', 'an', 'and', 'the'])")

    def test_stopwords_len(self):
        stopwords = Stopwords(["a", "an", "and", "the"])
        self.assertEqual(len(stopwords), 4)
