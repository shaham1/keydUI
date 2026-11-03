#!/usr/bin/env python3
import sys
import os

# Ensure src/ is in the module search path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "src"))

from keyd_manager.main import main

if __name__ == "__main__":
    main()

