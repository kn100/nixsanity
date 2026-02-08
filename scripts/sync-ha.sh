#!/usr/bin/env bash

# This script converts Home Assistant YAML configs to JSON so Nix can import them.
# Requires 'yj' (available in the project nix-shell).

BASE_DIR="modules/services/home-assistant"

for file in automations scenes scripts; do
  if [ -f "$BASE_DIR/$file.yaml" ]; then
    echo "Syncing $file.yaml -> $file.json..."
    yj < "$BASE_DIR/$file.yaml" > "$BASE_DIR/$file.json"
  fi
done

echo "Done!"
