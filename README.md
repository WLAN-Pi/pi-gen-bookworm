# WLAN Pi OS builder (bookworm)

Tool based on pi-gen to generate WLAN Pi OS images for bookworm.

## Docs

- [DOCS](docs/PRDs.md)
- [README](PI-GEN.md)

## Lite image update tools

- `boot-info`: diagnostic information about current boot/root partitions
- `update-alternate-partition`: updates the inactive partition
- `tryboot-alternative`: ensures tryboot is setup properly 
- `commit-current-partition`: makes autoboot.txt point towards booted partition confirming verification

Manual trigger tryboot:

- `sudo reboot 'N tryboot'`: tests booting to the updated partition safely. Use 1 or 2.
