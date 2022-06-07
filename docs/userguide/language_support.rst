================
Language Support
================

Available Languages
===================

* **European**: English (en)
* **Indian**: Hindi (hi)

Language Data
=============

Case
----

*Letter case* is the concept in which a language has two parallel character sets, each character in the first set having a single, corresponding, equivalent character in the second set.
Typically, one character set houses letters that are smaller in size, also known as *lowercase* letters, while the other set houses the larger letters that are also known as *uppercase* or *capital* letters.

The concept of case is found in European languages, and in languages that have adopted European scripts (Latin, Greek, Cyrillic) as their writing system.
Other languages such as Indian languages and the CJK languages do not have a concept of case.

In languages that do have a concept of case, the uppercase letters are typically used to indicate emphasis on a particular word(s).
For example, the first letter of the first word in a sentence is uppercase, the first letter of proper nouns such as names, places, etc. is uppercase, and so on.
Hence, the information that a given language has a concept of case or not, is valuable for keyword extraction.

In order to record this information, we maintain a single file ``data/case.txt``, containing a list of languages that have a concept of case.
Any language not in this list is assumed to **not** have a concept of case.

Stopwords
---------

In any given language, *stopwords* are a set of words that occur very frequently and that have little or no contribution towards semantic content in that language.
For example, in the preceding sentence, the words 'in', 'any', 'are', 'a', 'of', 'that', 'and', 'have', 'or', and 'no' all count as stopwords.

A list of stopwords, also known as a *stoplist*, is valuable for keyword extraction, since it tells the algorithm which words in the language have little or no semantic content, allowing the algorithm to "focus" on other words which are likely to have semantic content.
Many algorithms for keyword extraction use stopword lists in some way or the other.

There is no definition of a stopword as such, nor is there any standard mechanism by which stopword lists are generated.
One common mechanism of generating stopword lists involves taking a large corpus in the given language, finding the most frequently occurring words, and filtering out those words that have semantic content.
However, other mechanisms are also used.

Typically, stopword lists are 150-300 words in size, though the number may vary from language to language.
Languages with a relatively complex morphology, such as South Indian i.e. Dravidian languages, Sanskrit, etc., may tend to have shorter stopword lists.
On the other hand, languages like the CJK languages which do not define a word boundary require word *segmentation* to be carried out prior to generating stopword lists.
The "correctness" and "completeness" of a stopword list can only be judged by a speaker of the given language.

We maintain stopword lists for languages as text files under the directory ``data/stopwords``.
For example ``data/stopwords/stopwords_en.txt`` contains a list of English stopwords.
The sources of these various stopword lists are listed below:

============ =========================================================================== ========================================================================================
Language     Source                                                                      Link
============ =========================================================================== ========================================================================================
English (en) NLTK.                                                                       `link <https://github.com/nltk/nltk_data/blob/gh-pages/packages/corpora/stopwords.zip>`_
Hindi (hi)   Jha, Vandana; N, Manjunath; Shenoy, P Deepa; K R, Venugopal (2018), "Hindi  `link <https://data.mendeley.com/datasets/bsr3frvvjc/1>`_
             Language Stop Words List", Mendeley Data, V1, doi: 10.17632/bsr3frvvjc.1
============ =========================================================================== ========================================================================================
