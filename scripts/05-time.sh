#!/usr/bin/env bash
set -e

# Require TIMEZONE from 00-prompt.sh
: "${TIMEZONE:?TIMEZONE is not set}"

echo "⏱ Setting timezone to $TIMEZONE..."
timedatectl set-timezone "$TIMEZONE"
timedatectl set-ntp true

echo "✅ Time sync enabled and timezone set"
timedatectl status | grep "Time zone\|System clock"
