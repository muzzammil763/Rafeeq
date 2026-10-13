#!/usr/bin/env python3
"""
Sort ARB (Application Resource Bundle) files alphabetically by key
and remove duplicate entries. Automatically discovers all .arb files
in the lib/l10n/ directory.
"""

import json
import glob
import os
import sys


def sort_arb_file(filepath):
    """Sort keys in an ARB file A-Z and remove duplicates."""
    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Separate metadata keys (starting with @) from regular keys
    metadata = {}
    entries = {}
    for key, value in data.items():
        if key.startswith("@@"):
            # Top-level metadata like @@locale — keep at the top
            metadata[key] = value
        elif key.startswith("@"):
            # Per-key metadata like @appTitle — attach to parent key
            metadata[key] = value
        else:
            entries[key] = value

    # Sort regular keys alphabetically (case-insensitive)
    sorted_keys = sorted(entries.keys(), key=lambda k: k.lower())

    # Build the sorted dictionary
    sorted_data = {}

    # Add top-level metadata first (@@locale, etc.)
    for key in sorted(metadata.keys()):
        if key.startswith("@@"):
            sorted_data[key] = metadata[key]

    # Add sorted entries, each followed by its @-metadata if present
    for key in sorted_keys:
        sorted_data[key] = entries[key]
        meta_key = f"@{key}"
        if meta_key in metadata:
            sorted_data[meta_key] = metadata[meta_key]

    # Count stats
    duplicates_removed = len(data) - len(sorted_data)
    total_keys = len(entries)

    # Write back with consistent formatting
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(sorted_data, f, ensure_ascii=False, indent=2)
        f.write("\n")  # Trailing newline

    filename = os.path.basename(filepath)
    print(f"  ✅ {filename}: {total_keys} keys sorted", end="")
    if duplicates_removed > 0:
        print(f", {duplicates_removed} duplicate(s) removed", end="")
    print()


def main():
    arb_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "lib", "l10n")
    arb_files = sorted(glob.glob(os.path.join(arb_dir, "*.arb")))

    if not arb_files:
        print("⚠️  No ARB files found in lib/l10n/")
        sys.exit(1)

    print(f"Found {len(arb_files)} ARB file(s):")
    for filepath in arb_files:
        sort_arb_file(filepath)


if __name__ == "__main__":
    main()
