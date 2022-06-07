**Work in progress**

## Installation

#### From Source

Ensure Rust and Cargo are installed on your system.
Then, clone this repository and run
```
$ make build
```
This builds a wheel file that can be used for installation.
To install from the wheel file, start up a virtual environment and activate it:
```
$ python3 -m venv env
$ source env/bin/activate
```
and run the following:
```
$ pip3 install dist/keywey-0.1.0-py3-none-any.whl
```
This will install Keywey into the virtual environment.
Finally, to clean up the build artifacts, run
```
$ make clean
```
