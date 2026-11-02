# AGENTS.md

This file provides guidance to agents when working with code in this repository.

- The project uses shell scripts organized by installation phases:
  - `01-pre-installation/`
  - `02-disk-setup/`
  - `03-installation/`
  - `04-configure-system/`
- Custom libraries are located in `lib/`.
- The main entry point is `install.sh`, which must be run as root.
- Variables are defined in `vars.conf`, which must be present in both host and chroot environments.
- The installation process involves a chroot stage handled by `lib/run_chroot_scripts.sh`.
- Scripts in subdirectories are sourced by the main `install.sh` or within chroot by `lib/run_chroot_scripts.sh`.
- Ensure all new scripts are made executable (or the runner will do it).
