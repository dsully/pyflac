#!/usr/bin/env python

from distutils.core import setup, Extension
setup(
    name = "pyflac", version = "0.1",
    url="https://github.com/dsully/pyflac",
    description = "libFLAC wrapper",
    author = "David Collett, Joe Wreschnig, Dan Sully",
    author_email = "david.collett@dart.net.au",
    maintainer = "Dan Sully",
    license = "GNU GPL v2 or later",
    long_description = """
This is a simple wrapper for some of libFLAC, namely the file decoder, file
encoder, and metadata interfaces. Most of the functions of these interfaces
are working (I think).""",

    packages = ["flac"],
    ext_modules = [
        Extension('flac/_%s' % i, ['flac/%s_wrap.c' % i],
        library_dirs=['/usr/local/lib'],
        libraries=['FLAC']) for i in ["encoder", "decoder", "sw_metadata"]
    ]
)
