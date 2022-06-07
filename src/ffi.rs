//! FFI code.

use crate::lang_elements;
use pyo3::class::basic::CompareOp;
use pyo3::exceptions::{PyTypeError, PyValueError};
use pyo3::prelude::*;
use std::convert::TryFrom;
use std::fmt::{Display, Formatter, Result as FmtResult};

/// Wrapper struct around `lang_elements::Case`.
#[pyclass]
#[derive(Debug)]
struct Case(lang_elements::Case);

/// Facilitate conversion from a string like "exists" or "notdefined" to the corresponding variant
/// of the `Case` enum.
impl TryFrom<String> for Case {
    type Error = String;

    /// Conversion method.
    /// Method matches any string which when lowercased yields either one of "exists" or
    /// "notdefined". Returns an error "unknown case value ..." if the string has any other value.
    fn try_from(case: String) -> Result<Self, Self::Error> {
        match case.to_lowercase().as_ref() {
            "exists" => Ok(Self(lang_elements::Case::Exists)),
            "notdefined" => Ok(Self(lang_elements::Case::NotDefined)),
            _ => Err(format!("unknown case value '{}'", case)),
        }
    }
}

/// Create a string representation for the `Case` enum.
impl Display for Case {
    /// The `Case::Exists` variant has representation "exists", while the `Case::NotDefined`
    /// variant has representation "notdefined".
    fn fmt(&self, f: &mut Formatter<'_>) -> FmtResult {
        write!(
            f,
            "{}",
            match self.0 {
                lang_elements::Case::Exists => "exists",
                lang_elements::Case::NotDefined => "notdefined",
            }
        )
    }
}

#[pymethods]
impl Case {
    /// Constructor.
    /// Creates a `Case` from a string. If the string is invalid, it returns a `ValueError`.
    #[new]
    pub fn new(case: String) -> PyResult<Self> {
        Self::try_from(case).map_err(PyValueError::new_err)
    }

    /// Returns `Case(...)` with the string representation of the `Case` replacing the ellipsis
    /// `...`.
    pub fn __repr__(&self) -> String {
        format!("Case('{}')", self)
    }

    /// Returns the string representation of the `Case`.
    pub fn __str__(&self) -> String {
        format!("{}", self)
    }

    /// Implement equality comparison between `Case` values. Inequality comparisons such as >, <
    /// are not implemented (for obvious reasons) and return an error.
    pub fn __richcmp__(&self, other: &Self, op: CompareOp) -> PyResult<bool> {
        match op {
            CompareOp::Eq => Ok(self.0 == other.0),
            CompareOp::Ne => Ok(self.0 != other.0),
            _ => Err(PyTypeError::new_err(
                "operation not supported between instances of 'Case' and 'Case'",
            )),
        }
    }
}

/// Wrapper struct around `lang_elements::Stopwords`.
#[pyclass]
struct Stopwords(lang_elements::Stopwords);

#[pymethods]
impl Stopwords {
    /// Constructor.
    #[new]
    pub fn new(stopwords: Vec<String>) -> Self {
        Self(lang_elements::Stopwords(stopwords))
    }

    /// Length of the `Stopwords` struct, or the total number of stopwords.
    pub fn __len__(&self) -> usize {
        self.0.len()
    }

    /// Returns `Stopwords(...)` with the ellipsis `...` being replaced by the full list of
    /// stopwords.
    pub fn __repr__(&self) -> String {
        format!("Stopwords({:?})", self.0 .0).replace('"', "\'")
    }

    /// Identical to the `__repr__` method.
    pub fn __str__(&self) -> String {
        self.__repr__()
    }
}

/// Layout of the Python interface.
/// For now, everything is "dumped" into the root `keywey_core` namespace.
#[pymodule]
fn keywey_core(_py: Python<'_>, module: &PyModule) -> PyResult<()> {
    module.add_class::<Case>()?;
    module.add_class::<Stopwords>()?;
    Ok(())
}
