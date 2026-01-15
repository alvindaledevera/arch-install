#!/usr/bin/env bash
set -e

echo "⏱ Installing optional pacman packages..."

PACMAN_PKGS=(
    # -----------------------------
    # Core tools
    # -----------------------------
    git                # Version control system
    nano               # Terminal text editor
    code               # Visual Studio Code
    fastfetch          # CLI system info tool

    # -----------------------------
    # Networking & Wi-Fi
    # -----------------------------
    networkmanager     # Network manager for Wi-Fi and Ethernet
    wpa_supplicant     # Wi-Fi WPA authentication
    iw                 # CLI tool for wireless interfaces
    iwd                # Alternative Wi-Fi daemon

    # -----------------------------
    # Bluetooth
    # -----------------------------
    bluez              # Bluetooth stack
    bluez-utils        # Bluetooth CLI tools (bluetoothctl, etc.)
    bluedevil          # KDE GUI for Bluetooth

    # -----------------------------
    # Fingerprint / Smartcard
    # -----------------------------
    fprintd            # Fingerprint daemon
    libfprint          # Library for fingerprint devices
    pcsclite          # Smartcard support (used by some fingerprint readers)

    # -----------------------------
    # Power management
    # -----------------------------
    acpid              # Power management daemon (lid close, sleep, etc.)
    tlp                # Advanced power management for laptops
    tlp-rdw            # Radio device support for TLP
    powertop           # Power consumption analysis tool

    # -----------------------------
    # Audio
    # -----------------------------
    pipewire           # Modern audio server
    pipewire-pulse     # PipeWire replacement for PulseAudio
    pipewire-alsa      # ALSA support for PipeWire
    pavucontrol        # GUI volume control for PipeWire/PulseAudio

    # -----------------------------
    # KDE extras
    # -----------------------------
    kdeconnect         # Integrates phone with KDE desktop
    

    # -----------------------------
    # Firmware updates
    # -----------------------------
    fwupd              # Firmware updates (LVFS)

    reflector          # Automatically update and sort Arch Linux mirrors for faster package downloads


    mtools             # FAT filesystem utilities (USB, SD cards)
    sof-firmware        # Intel Sound Open Firmware (for modern audio devices)
    man-db              # Database and utilities for 'man' command
    man-pages           # Offline manual pages for Linux
    texinfo             # Tools to read/build info pages

)


pacman -Syu --needed --noconfirm "${PACMAN_PKGS[@]}"

echo "✅ Optional pacman packages installed"
