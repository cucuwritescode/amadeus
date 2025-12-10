#!/bin/bash

# Build script for Amadeus Sphinx documentation

set -e  # Exit on error

echo "🎵 Building Amadeus Documentation..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install/upgrade requirements
echo "Installing documentation dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf _build

# Build HTML documentation
echo "Building HTML documentation..."
sphinx-build -b html . _build/html

# Build PDF documentation (optional, requires LaTeX)
if command -v pdflatex &> /dev/null; then
    echo "Building PDF documentation..."
    sphinx-build -b latex . _build/latex
    cd _build/latex
    make
    cd ../..
fi

# Check for broken links
echo "Checking for broken links..."
sphinx-build -b linkcheck . _build/linkcheck

echo "✅ Documentation built successfully!"
echo "📁 HTML output: _build/html/index.html"

# Open in browser (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    open _build/html/index.html
fi

# Deactivate virtual environment
deactivate