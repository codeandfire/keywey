# ========================================================================================
# Makefile
#
# Commands:
#     Set up a development environment, with Rust and Python dependencies installed.
#     $ make <options> setup
#
#     Run Rust tests followed by Python tests.
#     $ make <options> test
#
#     Lint Rust source code followed by Python source code.
#     $ make <options> lint
#
#     Build documentation.
#     $ make <options> docs
#
#     Clean up the working directory.
#     $ make clean
#
# Options:
#     Change the Python interpreter (default: python3).
#     $ make PYTHON=pypy3 setup
#     $ make PYTHON=pypy3 test
#     $ make PYTHON=python3.7 lint
#     $ make PYTHON=python3.7 docs
#
#     Change the Rust toolchain (default: stable).
#     $ make RS_TOOLCHAIN=nightly setup
#     $ make RS_TOOLCHAIN=nightly test
#     $ make RS_TOOLCHAIN=nightly lint
#
#     Enable PyO3's extension module feature (default: disabled).
#     $ make EXT_MODULE=1 test
#
#     Enable PyO3's limited ABI feature (default: disabled).
#     $ make LIMITED_ABI=1 test
#
#     Allow the virtual environment to access Python packages installed system-wide
#     (default: disabled).
#     $ make SYSTEM_SITE_PACKAGES=1 setup
#
# More usage examples:
#     Combine options.
#     $ make PYTHON=pypy3 RS_TOOLCHAIN=nightly EXT_MODULE=1 LIMITED_ABI=1 test
#
#     Persist option values across commands using environment variables and the -e flag.
#     For example, instead of doing:
#     $ make PYTHON=pypy3 RS_TOOLCHAIN=nightly setup
#     $ make PYTHON=pypy3 RS_TOOLCHAIN=nightly test
#     you can do:
#     $ export PYTHON=pypy3
#     $ export RS_TOOLCHAIN=nightly
#     $ make -e setup
#     $ make -e test
# ========================================================================================

SHELL = /bin/bash

# Configuration
# -------------

PYTHON := python3
RS_TOOLCHAIN := stable

EXT_MODULE := 0
LIMITED_ABI := 0
SYSTEM_SITE_PACKAGES := 0

# Cargo command, with the toolchain included.
cargo := cargo +$(RS_TOOLCHAIN)

# name of the Python package.
py_package := keywey
# name of the Rust package.
rs_package := keywey_core

# name of the virtual environment.
virtualenv := .venv

# Cargo features
# --------------

# Set up the --features argument to be passed to cargo.
# Initially set up a string containing both features.
ext_module_feature := pyo3/extension-module
limited_abi_feature := pyo3/abi3
cargo_features := --features '$(ext_module_feature) $(limited_abi_feature)'

# If the extension-module feature has not been asked for, remove it from the string.
ifeq ($(EXT_MODULE),0)
	cargo_features := $(filter-out '$(ext_module_feature),$(cargo_features))
endif
# If the limited ABI feature has not been asked for, remove it from the string.
ifeq ($(LIMITED_ABI),0)
	cargo_features := $(filter-out $(limited_abi_feature)',$(cargo_features))
endif
# If both features have not been asked for, the string will be left as simply
# "--features"; set it to the empty string.
ifeq ($(cargo_features),--features)
	cargo_features := 
endif

# Virtualenv system packages
# --------------------------
# Allow the virtual environment to access Python packages that have been installed system-
# wide.
# This can be done by changing the line
# include-system-site-packages = false
# in pyvenv.cfg inside the virtual environment; the value false must be replaced with
# true.
# We use sed for carrying out this replacement.

ifneq ($(SYSTEM_SITE_PACKAGES),0)
	system_site_packages_cmd := sed -i \
	's/^include-system-site-packages = false$$/include-system-site-packages = true/' \
	./$(virtualenv)/pyvenv.cfg
else
	# No command has to be run, set this variable to an empty string.
	system_site_packages_cmd :=
endif

# requirements.txt hack
# ---------------------
# AFAIK currently, there is no command which can be used to extract the dependencies of a
# Python package from pyproject.toml and install them.
# The only existing way is to use a requirements.txt file, but maintaining a
# requirements.txt file along with a pyproject.toml essentially means we have to maintain
# two lists of dependencies, which can be prone to errors.
# This is a little hack which parses the pyproject.toml file to generate a
# requirements.txt-like file on-the-fly, containing the list of dependencies.

# In order to parse the pyproject.toml file, we require a package that can parse TOML.
toml_package := tomli

# The choice of the tomli package does not add an extra dependency to our project, because
# the tomli package is required by the build tools anyway.

# Python code to parse the pyproject.toml file and extract the dependencies.
# Note that the dependencies are extracted from three sources: project.dependencies,
# project.optional-dependencies (dev, tok, etc.), and build-system.requires.
define requirements_py_code
import $(toml_package); \
f = open('pyproject.toml', 'rb'); \
data = tomli.load(f); \
f.close(); \
print('\n'.join(data['project']['dependencies'] + \
	[dep for dep_list in data['project']['optional-dependencies'].values() for dep in dep_list] + \
	data['build-system']['requires']))
endef

# .so filenames
# -------------

# Post-compilation, this is the filename by which Rust stores the built library in the
# ./target directory.
rs_so_filename := lib$(rs_package).so

# For a .so file to be recognised by the Python interpreter, its name must follow a
# certain format.
# CPython can recognise a filename of the form $(rs_package).so, but it seems PyPy cannot
# (see this issue: https://github.com/PyO3/pyo3/issues/2394).
# The solution (see the same issue) is to use the Python sysconfig library to get the
# appropriate "suffix" of the .so file, depending on the Python interpreter and the
# architecture/platform.

# Python code to retrieve the suffix from sysconfig.
define ext_suffix_py_code
import sysconfig; \
print(sysconfig.get_config_var('EXT_SUFFIX'))
endef

# Run the Python code and store the suffix.
ext_suffix := $(shell /usr/bin/$(PYTHON) -c """$(ext_suffix_py_code)""")

# The filename that will be recognised by the Python interpreter.
py_so_filename := $(rs_package)$(ext_suffix)

# Help text
# ---------

# Extracts the comments at the top of this file and displays them.
.PHONY: help
help:
	@sed -n '2,54p' ./Makefile | sed -E 's/^#[[:space:]]?//'

# Development Rules
# -----------------

.PHONY: all
all: test

# ----------------------------------------------------------------------------------------

# Clean up the working directory.
# Remove the virtual environment, the Rust ./target directory, the Cargo lock file,
# symbolic links inside the Python source code directory, the __pycache__ directories, and
# the documentation build directory.
.PHONY: clean
clean:
	- rm -r ./$(virtualenv)
	/usr/bin/$(cargo) clean
	- rm ./Cargo.lock
	- rm ./src/$(py_package)/data
	- rm ./src/$(py_package)/*.so
	- rm -r ./src/$(py_package)/__pycache__
	- rm -r ./tests/__pycache__
	- rm -r ./docs/_build

# ----------------------------------------------------------------------------------------

# Build documentation.
.PHONY: docs
docs: ./$(virtualenv)
	. ./$(virtualenv)/bin/activate && cd docs && make html

# ----------------------------------------------------------------------------------------

# Lint source code.
.PHONY: lint
lint: rs_lint py_lint

# Lint Python code (run flake8).
.PHONY: py_lint
py_lint: ./$(virtualenv)
	- ./$(virtualenv)/bin/$(PYTHON) -m flake8 ./src/$(py_package)/*.py ./tests/*.py

# Lint Rust code (run clippy and rustfmt).
.PHONY: rs_lint
rs_lint:
	- /usr/bin/$(cargo) clippy --no-deps
	- /usr/bin/$(cargo) fmt --check

# ----------------------------------------------------------------------------------------

# Tests.
.PHONY: test
test: rs_test py_test

# Run Python tests.
# A symbolic link to the built Rust library is created inside the Python source code
# directory, in order to enable it being picked up by the Python interpreter.
# Another symbolic link to the ./data directory is created inside the Python source code
# directory, again to enable it being accessible by the Python interpreter.
# Note that the symbolic links use an absolute path to their destinations (using the
# abspath function provided by Make); this is vital to make them work correctly.
# Additionally, the (absolute path to the) ./src directory is added to PYTHONPATH, in
# order to enable Python to detect the keywey package while running tests.
.PHONY: py_test
py_test: ./target/debug/$(rs_so_filename) ./$(virtualenv)
	- ln -s $(abspath ./target/debug/$(rs_so_filename)) ./src/$(py_package)/$(py_so_filename)
	- ln -s $(abspath ./data) ./src/$(py_package)
	- export PYTHONPATH="$(abspath ./src):$${PYTHONPATH}" && \
	./$(virtualenv)/bin/$(PYTHON) -m unittest -v tests/test_*.py

# Run Rust tests.
.PHONY: rs_test
rs_test: ./target/debug/$(rs_so_filename)
	- /usr/bin/$(cargo) test --package $(rs_package) $(cargo_features)

# ----------------------------------------------------------------------------------------

# Perform Debug build.
# A rebuild should take place when the Rust source code changes, hence the dependency
# on ./src/*.rs files.
./target/debug/$(rs_so_filename): $(wildcard ./src/*.rs)
	export PYO3_PYTHON=$(PYTHON) && /usr/bin/$(cargo) build --package $(rs_package) \
	--lib $(cargo_features)

# ----------------------------------------------------------------------------------------

# Setup.
.PHONY: setup
setup: rs_setup py_setup

# Update Rust dependency versions and download crates.
.PHONY: rs_setup
rs_setup:
	/usr/bin/$(cargo) update -w
	/usr/bin/$(cargo) fetch

# Download/install Python dependencies.
.PHONY: py_setup
py_setup: ./$(virtualenv)
	$(system_site_packages_cmd)
	./$(virtualenv)/bin/$(PYTHON) -m pip install --upgrade pip
	./$(virtualenv)/bin/$(PYTHON) -m pip install $(toml_package)
	./$(virtualenv)/bin/$(PYTHON) -m pip install -r \
		<( ./$(virtualenv)/bin/$(PYTHON) -c """$(requirements_py_code)""" )

# Create a virtual environment.
./$(virtualenv):
	/usr/bin/$(PYTHON) -m venv ./$(virtualenv)
