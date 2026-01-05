#!/usr/bin/env bash

for p in "$EFI_PART" "$ARCH_PART"; do
  [[ -b "$p" ]] || { echo "❌ $p not found"; exit 1; }
done

if mount | grep -q "$ARCH_PART"; then
  echo "❌ $ARCH_PART is mounted"
  exit 1
fi
