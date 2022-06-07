from importlib_resources import files


def _load_stopwords(lang='en'):
    contents = files('data.stopwords').joinpath(f'stopwords_{lang}.txt').read_text()
    contents = contents.strip()
    stopwords = [word.strip() for word in contents.split('\n')]
    return stopwords


def _load_case(lang='en'):
    contents = files('data').joinpath('case.txt').read_text()
    contents = contents.strip()
    langs_with_case = [lang.strip() for lang in contents.split('\n')]
    if lang in langs_with_case:
        return 'exists'
    else:
        return 'notdefined'
