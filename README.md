# WLAN Pi OS builder (bookworm)

Tool based on pi-gen to generate WLAN Pi OS images for bookworm.

## Docs

- [DOCS](docs/PRDs.md)
- [README](PI-GEN.md)

## Lite image update tools

- `boot-info`: diagnostic information about current boot/root partitions
- `update-alternate-partition`: updates the inactive partition
- `tryboot-alternate`: ensures tryboot is setup properly 
- `commit-current-partition`: makes autoboot.txt point towards booted partition confirming verification

Manual trigger tryboot:

- `sudo reboot '2 tryboot'`: tests booting to partition set A (boot p2, root p5)
- `sudo reboot '3 tryboot'`: tests booting to partition set B (boot p3, root p6)

## Partition structure

The A/B partition layout uses:
- `p1`: CONFIGFS partition containing autoboot.txt and tryboot.txt
- `p2/p5`: Partition set A (boot/root)
- `p3/p6`: Partition set B (boot/root)
- `p7`: Home partition (shared)

Boot configuration is controlled by autoboot.txt in the CONFIGFS partition (p1), which determines which partition set boots by default.
