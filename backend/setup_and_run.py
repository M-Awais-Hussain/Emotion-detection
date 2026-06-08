#!/usr/bin/env python3
"""
Setup and run the Emotion Eye Backend API
This script handles virtual environment setup and server startup
"""

import subprocess
import sys
import os
import venv
from pathlib import Path

def main():
    backend_dir = Path(__file__).parent
    venv_dir = backend_dir / "venv"
    
    print("🚀 Emotion Eye Backend - Setup & Run")
    print("=" * 50)
    
    # Create virtual environment if it doesn't exist
    if not venv_dir.exists():
        print("\n📦 Creating virtual environment...")
        venv.create(venv_dir, with_pip=True)
        print("✅ Virtual environment created")
    
    # Determine Python executable in venv
    if sys.platform == "win32":
        python_exe = venv_dir / "Scripts" / "python.exe"
        pip_exe = venv_dir / "Scripts" / "pip.exe"
    else:
        python_exe = venv_dir / "bin" / "python"
        pip_exe = venv_dir / "bin" / "pip"
    
    # Install/upgrade pip
    print("\n📚 Updating pip...")
    subprocess.run([str(python_exe), "-m", "pip", "install", "--upgrade", "pip"], check=False)
    
    # Determine which requirements file to use
    print("\n" + "=" * 50)
    print("Choose installation type:")
    print("=" * 50)
    print("1. Minimal (Chat API only) - Recommended for quick setup")
    print("2. Full (Includes emotion detection ML model)")
    print("\n💡 Minimal is recommended if you don't have Visual C++ Build Tools installed")
    
    try:
        choice = input("\nEnter choice (1 or 2, default: 1): ").strip()
    except KeyboardInterrupt:
        print("\n\nSetup cancelled.")
        sys.exit(1)
    
    if choice == "2":
        requirements_file = backend_dir / "requirements.txt"
        install_type = "Full"
        print("\n⚠️  Full installation requires Visual C++ Build Tools for Windows")
        print("   See: https://visualstudio.microsoft.com/visual-cpp-build-tools/")
    else:
        requirements_file = backend_dir / "requirements-minimal.txt"
        install_type = "Minimal"
    
    # Install requirements
    print(f"\n📦 Installing {install_type} dependencies from {requirements_file.name}...")
    result = subprocess.run(
        [str(pip_exe), "install", "-r", str(requirements_file)],
        cwd=str(backend_dir),
        capture_output=False
    )
    
    if result.returncode != 0:
        print("\n⚠️  Warning: Some dependencies may not have installed correctly")
        print("   If the issue persists, try the Minimal install option (choice 1)")
        response = input("\nContinue anyway? (y/n): ").strip().lower()
        if response != 'y':
            sys.exit(1)
    else:
        print("✅ Dependencies installed successfully")
    
    # Run the server
    print("\n🚀 Starting Emotion Eye Backend Server...")
    print("=" * 50)
    print(f"Installation: {install_type}")
    print("Server will be available at: http://localhost:8000")
    print("API Documentation: http://localhost:8000/docs")
    print("\nPress Ctrl+C to stop the server")
    print("=" * 50)
    
    subprocess.run([str(python_exe), "main.py"], cwd=str(backend_dir))

if __name__ == "__main__":
    main()

