"""
SlangLang Python Package
This is a Python wrapper for the SlangLang compiler
"""

from setuptools import setup, find_packages

setup(
    name="slanglang",
    version="0.1.0",
    author="SlangLang Team",
    author_email="slanglang@example.com",
    description="A Gen Z slang programming language compiler",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/slanglang/slanglang",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: 3.8",
        "Programming Language :: 3.9",
        "Programming Language :: 3.10",
        "Programming Language :: 3.11",
    ],
    python_requires=">=3.7",
    install_requires=[
        "julia>=0.6.0",
    ],
    entry_points={
        "console_scripts": [
            "slanglang=slanglang.cli:main",
        ],
    },
    keywords="compiler, programming-language, julia, slang",
    project_urls={
        "Bug Reports": "https://github.com/slanglang/slanglang/issues",
        "Source": "https://github.com/slanglang/slanglang",
        "Documentation": "https://slanglang.github.io/slanglang",
    },
)