#!/bin/bash

# Basic Pitch Server Startup Script
# This script sets up the Python environment and starts the server

set -e

echo "🎵 Starting Basic Pitch Server..."
echo "================================="

# Check if Python 3.10 is available
if ! command -v python3.10 &> /dev/null; then
    echo "❌ Python 3.10 is not installed."
    echo "📥 Please install it with: brew install python@3.10"
    echo "ℹ️  Basic Pitch requires Python 3.10 or 3.11 (not 3.12+)"
    exit 1
fi

# Check if we're in the server directory
if [ ! -f "main.py" ]; then
    echo "❌ Please run this script from the basic-pitch-server directory"
    exit 1
fi

# Remove existing venv if it exists (to ensure clean Python 3.10 environment)
if [ -d "venv" ]; then
    echo "🧹 Removing existing virtual environment..."
    rm -rf venv
fi

# Create virtual environment with Python 3.10
echo "📦 Creating Python 3.10 virtual environment..."
python3.10 -m venv venv

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "⬆️  Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo "📥 Installing dependencies..."
pip install -r requirements.txt

# Start the server
echo "🚀 Starting Basic Pitch server on http://localhost:8000"
echo "📊 Server logs will appear below..."
echo "🛑 Press Ctrl+C to stop the server"
echo ""

python main.py