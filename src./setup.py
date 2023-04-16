from setuptools import setup
from Cython.Build import cythonize
import Cython.Compiler.Options
Cython.Compiler.Options.annotate = True
import numpy

setup(
    ext_modules = cythonize('panini.pyx', annotate = True), include_dirs=[numpy.get_include()]
)
