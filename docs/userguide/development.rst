=================
Development Guide
=================

Directory Structure
===================

The following schematic outlines the directory structure of this project::

        keywey
        │
        ├── Cargo.lock
        ├── Cargo.toml
        │
        ├── data                     <-- Language data
        │   ├── ...
        │   └── stopwords
        │       └── ...
        │
        ├── docs                     <-- Documentation
        │   ├── index.rst
        │   ├── ...
        │   └── userguide
        │       └── ...
        │
        ├── LICENSE
        ├── Makefile
        ├── pyproject.toml
        ├── README.md
        │
        ├── src                      <-- Source code directory
        │   │
        │   ├── keywey               <-- Python source code
        │   │   ├── __init__.py
        │   │   └── ...
        │   │ 
        │   ├── lib.rs               <-- Rust source code
        │   └── ...
        │  
        └── tests                    <-- Python tests
            ├── test_foo.py
            └── ...

Some notes:

* Configuration files are limited to ``Cargo.toml`` for the Rust code and ``pyproject.toml`` for the Python code.
* All Python-Rust FFI code is limited to the file ``src/ffi.rs``.
  This file defines thin wrappers around Rust classes and functions, and exposes them to the Python interface.
  Tests for the FFI code are hosted on the Python side in the file ``tests/test_ffi.py``.
* The ``tests`` directory houses the Python unit and integration tests.
  Note that there is no directory for the Rust tests; Rust unit tests are housed within the Rust source code as per convention, and there are no Rust integration tests.

Tooling
=======

Please refer this section in order to understand the tools we have chosen to use for various components of this project like testing, building, etc., and the reasons for opting for the chosen tool in favour of other, alternative tools.

Testing
-------

**Rust**

Tool used: `Cargo Test <https://doc.rust-lang.org/cargo/guide/tests.html>`_

================================================================ ===================================================================================================================
Options                                                          Details
================================================================ ===================================================================================================================
`Cargo Test <https://doc.rust-lang.org/cargo/guide/tests.html>`_ Framework for running unit tests, integration tests and doc tests. Standard in Rust projects.
================================================================ ===================================================================================================================

**Python**

Tool used: `Unittest <https://docs.python.org/3/library/unittest.html>`_

================================================================ ===================================================================================================================
Options                                                          Details
================================================================ ===================================================================================================================
`Unittest <https://docs.python.org/3/library/unittest.html>`_    Basic testing framework, included within the Python standard library. Simple enough for our current requirements.
`PyTest <https://pytest.org/>`_                                  Advanced testing framework. Currently there seems to be no benefit in moving to PyTest.
================================================================ ===================================================================================================================

Python-Rust FFI
---------------

Tool used: `PyO3 <https://github.com/PyO3/pyo3>`_

=============================================================== =====================================================================================================================
Options                                                         Details
=============================================================== =====================================================================================================================
`Milksnake <https://github.com/getsentry/milksnake>`_           Setuptools extension for linking native modules with the Python interpreter. Requires the Rust library to explicitly
                                                                expose a C interface (``pub extern unsafe "C" ...``).
`Rust-CPython <https://github.com/dgrunwald/rust-cpython>`_     Rust bindings for the Python interpreter. As the name suggests, it is limited to CPython and will not support
                                                                alternative Python implementations, such as PyPy. Has probably been superseded by PyO3.
`PyO3 <https://github.com/PyO3/pyo3>`_                          Rust bindings for the Python interpreter. Supports both CPython and PyPy (versions 3.7 and up). Macro-based style
                                                                (``#[pyclass]``, ``#[pyfunction]``, ``#[pymethods]``) is very convenient and reduces boilerplate.
=============================================================== =====================================================================================================================

Build Tools
-----------

**Python backend**

Tool used: `Setuptools <https://setuptools.pypa.io/en/latest/>`_

=============================================================== =====================================================================================================================
Options                                                         Details
=============================================================== =====================================================================================================================
`Setuptools <https://setuptools.pypa.io/en/latest/>`_           Traditional build tool for Python projects. Supports native extension modules.
`Flit <https://flit.pypa.io/en/latest/>`_                       Alternative build tool for Python projects. Does not support native extensions, only meant for pure Python projects.
`Poetry <https://python-poetry.org/>`_                          Alternative build tool for Python projects. Again, seems to be only meant for pure Python projects.
=============================================================== =====================================================================================================================

**Rust integration**

Tool used: Manual build

=============================================================== =====================================================================================================================
Options                                                         Details
=============================================================== =====================================================================================================================
`Setuptools-Rust <https://github.com/PyO3/setuptools-rust>`_    Rust extension for Setuptools. Adds to Setuptools commands and other functionality required to build Rust projects.
                                                                The issue with this is that it seems to use a ``setup.py`` based build process, which has been deprecated since
                                                                `PEP 517 <https://peps.python.org/pep-0517/>`_, in favour of a ``pyproject.toml`` based configuration.
`Maturin <https://github.com/PyO3/maturin>`_                    Tool to automate the entire process of building a Rust library, a Python wheel, installing and even publishing it.
                                                                Supports a ``pyproject.toml`` based configuration. However, this has some issues. The docs state that every time a
                                                                change is made to the Rust source code, ``maturin develop`` should be run, which performs a quick debug build.
                                                                However, it seems that this command rebuilds the wheel and reinstalls the package, every time it is run, which is
                                                                very slow. At the same time, the docs state that to prevent rebuilds with every change to the *Python* source code,
                                                                editable installs using ``pip -e install .`` are supported. Overall, it is confusing that a change to the Rust source
                                                                code requires the wheel to be rebuilt and reinstalled, but a change to the Python source does not. Another issue is
                                                                that package data support is not mentioned in the documentation.
Manual build                                                    Manual build refers to explicitly running the ``cargo build`` commands, and
                                                                `copying <https://pyo3.rs/v0.16.4/building_and_distribution.html#manual-builds>`_ the built Rust library into the
                                                                Python source code directory. The issue with this approach is that the built library is not recognised by Setuptools
                                                                while building the source distribution (and consequently the wheel), since the library has not been built from within
                                                                Setuptools. It is possible to workaround this issue using a ``MANIFEST.in`` file which explicitly orders Setuptools
                                                                to include this built library file, but this is not ideal. We hope to find a better solution soon.
=============================================================== =====================================================================================================================

Linters and Formatters
----------------------

**Rust**

Tools used: `Clippy <https://github.com/rust-lang/rust-clippy>`_ and `Rustfmt <https://github.com/rust-lang/rustfmt>`_

=============================================================== =====================================================================================================================
Options                                                         Details
=============================================================== =====================================================================================================================
`Clippy <https://github.com/rust-lang/rust-clippy>`_            Linter that assists in writing more idiomatic Rust code. Standard in Rust projects.
`Rustfmt <https://github.com/rust-lang/rustfmt>`_               Standard autoformatter for Rust projects. Since we are not in favour of automatic formatting, we run ``rustfmt`` in
                                                                ``--check`` mode, in which it presents a diff between the original and expected formatting.
=============================================================== =====================================================================================================================

**Python**

Tool used: `Flake8 <https://flake8.pycqa.org/en/latest/index.html>`_

=============================================================== =====================================================================================================================
Options                                                         Details
=============================================================== =====================================================================================================================
`Black <https://github.com/psf/black>`_                         Opinionated autoformatter for Python projects. We are not in favour of the Black code style!
`Flake8 <https://flake8.pycqa.org/en/latest/index.html>`_       Standard linter for Python projects. Checks code style and formatting, among other lints. We use ``flake8`` with a
                                                                maximum line length setting of 90 characters.
`Mypy <http://mypy-lang.org/>`_                                 Standard static type checker for Python projects. Currently we are not using type hints in our code. This is primarily 
                                                                because a fair amount of our code is in Rust, and therefore the Python API that wraps around the Rust code will have
                                                                limited scope for type checking. We are open to *type stubs* (``.pyi`` files) for integration with other projects
                                                                that may use type hints, but we are not working on this right now.
=============================================================== =====================================================================================================================

CLI Automation Tools
--------------------

Tool used: Make



=============================================================== =====================================================================================================================
Options                                                         Details
=============================================================== =====================================================================================================================
`Tox <https://tox.wiki/en/latest/index.html>`_                  Tool to automate testing of Python projects amid different choices and versions of Python interpreters. Can also be
                                                                used to run non Python-testing related commands, such as ``tox -e docs`` to build documentation. However, with its
                                                                primary focus being Python and Python testing, we feel that it will be insufficient to handle procedures geared
                                                                towards the Rust end, such as building and testing the Rust code.
`Nox <https://github.com/wntrblm/nox>`_                         Similar to Tox.
Make                                                            The well-known GNU Make, originally used to compile C projects but can be extended for any sort of CLI automation.
                                                                Time-tested tool, which is installed by default on many Linux systems. Full-featured utility with a lot of
                                                                functionality, and a detailed user manual. The only downside is the slightly obscure syntax of the Makefile.
`Invoke <https://www.pyinvoke.org/>`_                           General-purpose automation tool, viewed as a Python replacement of GNU Make / Ruby's Rake. Its general-purpose nature
                                                                makes it more suitable for this project than Tox and Nox. Since configuration is specified through Python files, it
                                                                has a friendlier syntax than the Makefile, and also allows for modularization of rules into collections and
                                                                namespaces. Invoke's design and philosophy has many benefits, but requires some time to learn and adapt to, and
                                                                currently we don't wish to incur this overhead!
=============================================================== =====================================================================================================================

Benchmarking
------------

Not implemented yet.

Documentation
-------------

This user guide has been written in `Sphinx <https://www.sphinx-doc.org/>`_.

**API Reference**

Tool used: *Undecided*

=============================================================== =====================================================================================================================
Options                                                         Details
=============================================================== =====================================================================================================================
`Rustdoc <https://doc.rust-lang.org/rustdoc/index.html>`_       Standard documentation generator for Rust projects. Extracts documentation comments from source code and converts it
                                                                into HTML. Markdown syntax is supported.
`Sphinx <https://www.sphinx-doc.org/>`_                         Sphinx also supports extracting docstrings from Python source code and converting it into HTML (among other formats),
                                                                by means of an `extension <https://www.sphinx-doc.org/en/master/usage/quickstart.html#autodoc>`_. reStructuredText
                                                                syntax is supported.
=============================================================== =====================================================================================================================

Development Workflow
====================

At the root of the project directory, there is a Makefile that can be used to run common development tasks.
To start development on this repository, clone the repository and run::

        $ make setup

to set up a development environment with all Rust and Python packages installed.
After making any change to the codebase, run::

        $ make test

to run Rust and Python tests, and see if they pass.
Avoid trying to test this package interactively -- if you add any new behaviour/functionality to the package, add one or more tests to check that it works.
Note also that there is no separate "build" command to build the Rust library -- this command will rebuild the Rust library if necessary.

Occasionally, preferably prior to making a commit, run::

        $ make lint

to apply linters and formatters on the source code.
Try and resolve all the errors produced, unless you have a good reason to *not* listen to the linter/formatter.

To build documentation (this user guide), run::

        $ make docs

and view the file ``.../keywey/docs/_build/html/index.html`` in a browser.

Finally, to clean up the working directory, i.e. remove build artifacts and other unnecessary files, run::

        $ make clean

The commands listed above also take certain options.
To get details about these options and how they can be used, run::

        $ make help
