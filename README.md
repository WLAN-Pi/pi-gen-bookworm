# WLAN Pi OS builder (bookworm)

Tool based on pi-gen to generate WLAN Pi OS images for bookworm.

## Docs

- [DOCS](docs/PRDs.md)
- [README](PI-GEN.md)

## A/B partition management tools

- `boot-info`: Shows current partition set, CONFIGFS configuration, and boot history
- `update-alternate-partition <image.img.gz>`: Updates the inactive partition set from compressed OS image
- `tryboot-alternate`: Configures CONFIGFS tryboot.txt for testing the alternate partition set
- `commit-current-partition`: Updates CONFIGFS autoboot.txt to make current partition set the default

Manual trigger tryboot:

- `sudo reboot '2 tryboot'`: tests booting to partition set A (boot p2, root p5)
- `sudo reboot '3 tryboot'`: tests booting to partition set B (boot p3, root p6)

Notes:

- Tryboot tests are temporary - failed boots automatically revert to the original partition
- The home partition (p7) is shared between both partition sets
- CONFIGFS autoboot.txt controls default boot behavior after power loss

## Typical A/B update workflow

1. Update the inactive partition: `sudo update-alternate-partition <image.img.gz>`
2. Configure tryboot: `sudo tryboot-alternate` 
3. Test the update: Use the reboot command displayed by `tryboot-alternate`
4. Verify functionality: `sudo boot-info`
5. Make permanent: `sudo commit-current-partition`

## Partition structure

The A/B partition layout uses:
- `p1`: CONFIGFS partition containing autoboot.txt and tryboot.txt
- `p2/p5`: Partition set A (boot/root)
- `p3/p6`: Partition set B (boot/root)
- `p7`: Home partition (shared)

Boot configuration is controlled by autoboot.txt in the CONFIGFS partition (p1), which determines which partition set boots by default.
