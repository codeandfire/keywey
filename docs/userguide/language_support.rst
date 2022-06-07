================
Language Support
================

Available Languages
===================

* **European**: English (en)
* **Indic**: Hindi (hi)

Language Data
=============

Case
----

*Letter case* is the concept in which a language has two parallel character sets, each character in the first set having a single, corresponding, equivalent character in the second set.
Typically, one character set houses letters that are smaller in size, also known as *lowercase* letters, while the other set houses the larger letters that are also known as *uppercase* or *capital* letters.

The concept of case is found in European languages, and in languages that have adopted their scripts (Latin, Greek, Cyrillic) as their writing system.
Other languages such as Indic languages and the CJK languages do not have a concept of case.

In languages that do have a concept of case, the uppercase letters are typically used to indicate emphasis on a particular word(s).
For example, the first letter of the first word in a sentence is uppercase, the first letter of proper nouns such as names, places, etc. is uppercase, and so on.
Hence, the information that a given language has a concept of case or not, is valuable for keyword extraction.

In order to record this information, we maintain a single file ``data/case.txt``, containing a list of languages that have a concept of case.
Any language not in this list is assumed to **not** have a concept of case.
