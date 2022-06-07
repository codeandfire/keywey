/// "Language elements" module.
///
/// This module defines certain "entities" that are specific to a given language.

/// Language case.
#[derive(Clone, Debug, PartialEq)]
pub enum Case {
    Exists,
    NotDefined,
}

/// Stopword list.
#[derive(Clone, Debug, Default)]
pub struct Stopwords(pub Vec<String>);

impl Stopwords {
    pub fn is_empty(&self) -> bool {
        self.0.is_empty()
    }

    pub fn len(&self) -> usize {
        self.0.len()
    }
}
