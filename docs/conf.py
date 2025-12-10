#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Amadeus documentation build configuration file
#
# This file is executed with the current directory set to its containing dir.

import os
import sys
from datetime import datetime

# -- Path setup --------------------------------------------------------------
# Add project root to path for autodoc of Python modules
sys.path.insert(0, os.path.abspath('../basic-pitch-server'))
sys.path.insert(0, os.path.abspath('../Amadeus-Fresh'))

# -- Project information -----------------------------------------------------
project = 'Amadeus'
author = 'Amadeus Development Team'
copyright = f'{datetime.now().year}, {author}'
release = '1.0.0'
version = '1.0.0'

# -- General configuration ---------------------------------------------------
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.autosummary',
    'sphinx.ext.viewcode',
    'sphinx.ext.intersphinx',
    'sphinx.ext.mathjax',
    'sphinx.ext.napoleon',
    'sphinx.ext.todo',
    'sphinx_copybutton',
    'sphinx_rtd_theme',
    'sphinx_tabs.tabs',
]

# Napoleon settings for Google/NumPy style docstrings
napoleon_google_docstring = True
napoleon_numpy_docstring = True
napoleon_include_init_with_doc = True
napoleon_include_private_with_doc = False
napoleon_include_special_with_doc = True
napoleon_use_admonition_for_examples = False
napoleon_use_admonition_for_notes = False
napoleon_use_admonition_for_references = False
napoleon_use_ivar = False
napoleon_use_param = True
napoleon_use_rtype = True
napoleon_preprocess_types = False
napoleon_type_aliases = None

# Add any paths that contain templates here
templates_path = ['_templates']

# List of patterns to ignore when looking for source files
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store', 'venv', '.venv', '*.md', 'README.md']

# The suffix(es) of source filenames
source_suffix = {
    '.rst': None,
}

# The master toctree document
master_doc = 'index'

# -- Options for HTML output -------------------------------------------------

# Theme configuration
html_theme = 'sphinx_rtd_theme'

# Logo configuration (exactly like librosa)
html_logo = 'img/amadeuslogo.png'

html_theme_options = {
    'canonical_url': '',
    'analytics_id': '',
    'analytics_anonymize_ip': False,
    'logo_only': True,  # Show only logo, no project name in sidebar
    'display_version': True,
    'prev_next_buttons_location': 'bottom',
    'style_external_links': True,
    'vcs_pageview_mode': 'blob',
    'style_nav_header_background': '#2980B9',
    # Toc options
    'collapse_navigation': True,
    'sticky_navigation': True,
    'navigation_depth': 4,
    'includehidden': True,
    'titles_only': False
}

# Add any paths that contain custom static files
html_static_path = ['_static']

# Custom CSS files
html_css_files = [
    'custom.css',
]

# Custom sidebar templates
html_sidebars = {
    '**': [
        'globaltoc.html',
        'relations.html',
        'sourcelink.html',
        'searchbox.html',
    ]
}

# Output file base name for HTML help builder
htmlhelp_basename = 'Amadeusdoc'

# -- Options for LaTeX output ------------------------------------------------

# LaTeX logo (same as HTML but for PDF generation)
latex_logo = 'img/amadeuslogo.png'

latex_elements = {
    'papersize': 'letterpaper',
    'pointsize': '10pt',
    'preamble': '',
    'figure_align': 'htbp',
}

# Grouping the document tree into LaTeX files
latex_documents = [
    (master_doc, 'Amadeus.tex', 'Amadeus Documentation',
     'Amadeus Development Team', 'manual'),
]

# -- Options for manual page output ------------------------------------------
man_pages = [
    (master_doc, 'amadeus', 'Amadeus Documentation',
     [author], 1)
]

# -- Options for Texinfo output ----------------------------------------------
texinfo_documents = [
    (master_doc, 'Amadeus', 'Amadeus Documentation',
     author, 'Amadeus', 'iOS tool for musicians to analyze chord progressions.',
     'Miscellaneous'),
]

# -- Extension configuration -------------------------------------------------

# Todo extension
todo_include_todos = True

# Intersphinx mapping
intersphinx_mapping = {
    'python': ('https://docs.python.org/3/', None),
    'numpy': ('https://numpy.org/doc/stable/', None),
    'librosa': ('https://librosa.org/doc/latest/', None),
}

# Autodoc configuration
autodoc_default_options = {
    'members': True,
    'member-order': 'bysource',
    'special-members': '__init__',
    'undoc-members': True,
    'exclude-members': '__weakref__'
}

# Copy button configuration
copybutton_exclude = '.linenos, .gp'
copybutton_prompt_text = r'>>> |\.\.\. |\$ |In \[\d*\]: | {2,5}\.\.\.: | {5,8}: '
copybutton_prompt_is_regexp = True