#!/bin/bash

echo "==> Closing CrossOver..."
killall "CrossOver" 2>/dev/null || true

PLIST_PATH="$HOME/Library/Preferences/com.codeweavers.CrossOver.plist"
if [ -f "$PLIST_PATH" ]; then
    echo "==> Updating FirstRunDate in CrossOver preferences..."
    defaults write com.codeweavers.CrossOver FirstRunDate -date "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
else
    echo "(!) CrossOver plist not found at $PLIST_PATH. Run CrossOver at least once first."
fi

BOTTLES_DIR="$HOME/Library/Application Support/CrossOver/Bottles"

if [ -d "$BOTTLES_DIR" ]; then
    echo "==> Processing bottles in $BOTTLES_DIR..."
    
    for reg_file in "$BOTTLES_DIR"/*/system.reg; do
        if [ -f "$reg_file" ]; then
            bottle_name=$(basename "$(dirname "$reg_file")")
            echo "  -> Cleaning system.reg for bottle: $bottle_name"
            
            
            cp "$reg_file" "${reg_file}.bak"
            
            python3 -c "
import sys, re

reg_path = sys.argv[1]
with open(reg_path, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# Pattern matching the CodeWeavers CXOffice section block until the next section header or end of file
pattern = r'\[Software\\\\CodeWeavers\\\\CrossOver\\\\CXOffice\][^\[]*'
cleaned = re.sub(pattern, '', content)

with open(reg_path, 'w', encoding='utf-8') as f:
    f.write(cleaned.strip() + '\n')
" "$reg_file"
        fi
    done
    echo "==> All bottles have been updated."
else
    echo "(!) No bottles directory found at $BOTTLES_DIR"
fi

echo "==> Done! You can now launch CrossOver."