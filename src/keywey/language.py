from importlib_resources import files
from typing import Optional


def _load_stopwords(lang: Optional[str] = 'en') -> list[str]:
    try:
        contents = files('data.stopwords').joinpath(f'stopwords_{lang}.txt').read_text()
    except FileNotFoundError:
        if len(lang) != 2:
            raise ValueError(f"invalid language code '{lang}'")
        else:
            raise RuntimeError(f"no support for language with code '{lang}'")
    contents = contents.strip()
    stopwords = [word.strip() for word in contents.split('\n')]
    return stopwords


def _load_case(lang: Optional[str] = 'en') -> str:
    if len(lang) != 2:
        raise ValueError(f"invalid language code '{lang}'")
    contents = files('data').joinpath('case.txt').read_text()
    contents = contents.strip()
    langs_with_case = [lang.strip() for lang in contents.split('\n')]
    if lang in langs_with_case:
        return 'exists'
    else:
        return 'notdefined'
