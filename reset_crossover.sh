#!/bin/bash

# Close CrossOver if running
echo "Closing CrossOver..."
pkill -x CrossOver || echo "CrossOver was not running."
sleep 2

# Reset Trial Date
echo "Resetting CrossOver Trial Date..."
PLIST_DOMAIN="com.codeweavers.CrossOver"
CURRENT_DATE=$(date -u "+%Y-%m-%dT%H:%M:%SZ")
defaults write "$PLIST_DOMAIN" FirstRunDate -date "$CURRENT_DATE"
echo "Trial date reset to $CURRENT_DATE."

# Fix Expired Bottles
echo "Scanning for expired bottles..."
BOTTLES_DIR="$HOME/Library/Application Support/CrossOver/Bottles"

if [ -d "$BOTTLES_DIR" ]; then
    for bottle in "$BOTTLES_DIR"/*; do
        if [ -d "$bottle" ]; then
            REG_FILE="$bottle/system.reg"
            if [ -f "$REG_FILE" ]; then
                echo "Processing bottle: $(basename "$bottle")"
                sed -i.bak '/\[Software\\\\CodeWeavers\\\\CrossOver\\\\CXOffice\]/,/^$/d' "$REG_FILE"
                echo "Cleaned registry for: $(basename "$bottle")"
            fi
        fi
    done
else
    echo "No Bottles folder found at $BOTTLES_DIR"
fi

echo "Finished. You can now launch CrossOver."
