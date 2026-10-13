#!/usr/bin/env python3
"""
Verify ARB (Application Resource Bundle) files for missing keys.
Automatically discovers all .arb files in the lib/l10n/ directory,
finds the union of all keys, and reports which files are missing which keys.
"""

import json
import glob
import os
import sys

def get_keys_from_arb(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)
    
    # Just return regular keys (not starting with @)
    keys = set()
    for key in data.keys():
        if not key.startswith("@"):
            keys.add(key)
    return keys

def main():
    arb_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "lib", "l10n")
    arb_files = sorted(glob.glob(os.path.join(arb_dir, "*.arb")))

    if not arb_files:
        print("⚠️  No ARB files found in lib/l10n/")
        sys.exit(1)

    all_keys = set()
    file_keys = {}

    # Extract keys from all files
    for filepath in arb_files:
        filename = os.path.basename(filepath)
        keys = get_keys_from_arb(filepath)
        file_keys[filename] = keys
        all_keys.update(keys)

    print(f"Total unique keys across all files: {len(all_keys)}\n")

    has_missing = False

    # Check each file for missing keys
    for filename, keys in file_keys.items():
        missing_keys = all_keys - keys
        if missing_keys:
            has_missing = True
            print(f"❌ {filename} is missing {len(missing_keys)} key(s):")
            for key in sorted(missing_keys):
                print(f"  - {key}")
            print()
        else:
            print(f"✅ {filename} has all {len(all_keys)} keys.\n")

    if has_missing:
        sys.exit(1)
    else:
        print("All ARB files are fully synced! 🎉")

if __name__ == "__main__":
    main()
