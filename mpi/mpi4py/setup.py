from setuptools import setup, Extension
setup(
        name="spam",
        version="1.0",
        ext_modules=[
            Extension(
                "spam",  # Module name as imported in Python
                sources=["spam.c"],  # List of C/C++ source files
                # Optional: other compilation flags, libraries, etc.
            )
        ]
    )
