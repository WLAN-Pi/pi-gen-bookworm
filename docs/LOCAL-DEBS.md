# Local debs: sideloading, removing, and rebuilding images

## Why sideload local debs?

This repo builds WLAN Pi OS images on Debian **Trixie**, but most `wlanpi-*`
packages on packagecloud are still built for **Bookworm**. Packages that ship a
Python virtualenv (wlanpi-core, wlanpi-webui, wlanpi-fpms) embed the Python
version they were built against: a Bookworm build creates
`/opt/<pkg>/lib/python3.11/` with cp311 compiled extensions, but its
`bin/python3` symlink resolves to the system interpreter — Python 3.13 on
Trixie. The service then fails at import time even though the package installs
cleanly. Until upstream publishes Trixie builds, we rebuild those packages
locally and sideload the debs into the image.

## The two sideload mechanisms

### 1. `local-debs/` directory (generic)

Any `.deb` dropped into `local-debs/` at the repo root is installed by the
`04-local-debs` sub-stage in both variants. Good for standalone packages with
no dependencies on other wlanpi packages (currently: the custom kernel).

**Ordering caveat:** sub-stages run alphabetically within a stage.

- `wlanpi1-lite`: `04-local-debs` runs **before** `08-install-wlanpi-packages`
- `wlanpi2-full`: `04-install-wlanpi-packages` runs **before** `04-local-debs`

In the lite build, a deb in `local-debs/` that depends on another wlanpi
package (e.g. webui depends on wlanpi-core) installs before that dependency
exists, so apt satisfies it from packagecloud — pulling in exactly the
Bookworm build we're trying to avoid. Debs with wlanpi dependencies belong in
mechanism 2.

### 2. Explicit sideload in the wlanpi-packages stage (dependency-ordered)

The wlanpi app packages are handled in the `00-run.sh` of each variant's
install-wlanpi-packages sub-stage:

- `wlanpi1-lite/08-install-wlanpi-packages/00-run.sh`
- `wlanpi2-full/04-install-wlanpi-packages/00-run.sh`

Each script copies debs from `~/source/<pkg>/` into the chroot's `/tmp` and
installs them in dependency order (wlanpi-core first, dependents after),
**before** apt processes the `01-packages` list. Currently sideloaded:

| Package       | Local deb                                                        | Variants   |
|---------------|------------------------------------------------------------------|------------|
| wlanpi-core   | `~/source/wlanpi-core/wlanpi-core_2.1.11-1~pr131_arm64.deb` (experimental PR 131 build) | lite, full |
| wlanpi-common | `~/source/wlanpi-common/wlanpi-common_1.1.43+trixie3_arm64.deb`  | lite, full |
| wlanpi-webui  | `~/source/wlanpi-webui/wlanpi-webui_1.4.0-2_arm64.deb`           | lite, full |
| wlanpi-fpms   | `~/source/wlanpi-fpms/wlanpi-fpms_1.4.14_arm64_trixie.deb`       | full only  |

## Adding a local deb

1. **Verify the deb is actually a Trixie build** (for venv-shipping packages):

   ```bash
   dpkg-deb -x <pkg>.deb /tmp/check
   cat /tmp/check/opt/<pkg>/pyvenv.cfg   # want: version = 3.13.x
   ls /tmp/check/opt/<pkg>/lib/          # want: python3.13
   ```

2. **Wire it into both variants.** For a standalone deb, copy it into
   `local-debs/`. For a wlanpi app package, add matching lines to both
   `00-run.sh` scripts:

   ```bash
   cp /home/jakesnyder/source/<pkg>/<pkg>_<ver>_arm64.deb "${ROOTFS_DIR}/tmp/"
   ...
   apt-get install -y --reinstall --allow-downgrades /tmp/<pkg>_<ver>_arm64.deb
   ...
   rm -f ... /tmp/<pkg>_<ver>_arm64.deb
   ```

   Place the `apt-get install` line **after** wlanpi-core if the package
   depends on it. Always pass `--reinstall --allow-downgrades` (see gotcha
   below).

3. **Comment the package out of the `01-packages` list** in both variants so
   apt doesn't fight the sideload, with the standard annotation:

   ```
   #wlanpi-webui (installed via 00-run.sh from local build)
   ```

   Files: `wlanpi1-lite/08-install-wlanpi-packages/01-packages` and
   `wlanpi2-full/04-install-wlanpi-packages/01-packages`.

## Removing a local deb (reverting to packagecloud)

Do this once upstream publishes a Trixie-compatible build:

1. Delete the package's `cp`, `apt-get install`, and `rm -f` references from
   both `00-run.sh` scripts (or remove the deb from `local-debs/`).
2. Uncomment the package name in both `01-packages` lists.
3. If the sideloaded version was **higher** than the packagecloud version,
   apt won't downgrade an existing work rootfs — run a clean build
   (`CLEAN=1`) or remove the variant's rootfs under `work/` so the
   packagecloud version installs fresh.

## Triggering builds

Native arm64 build (this host), must run as root:

```bash
cd ~/source/pi-gen-bookworm
sudo ./build-arm64.sh
```

- Settings come from `config` (release=trixie, both variants via
  `STAGE_LIST="wlanpi1-lite wlanpi2-full"`, apt-cacher-ng proxy on
  localhost:3142).
- Useful overrides (export before running, or put in a `-c extra-config`):
  - `CLEAN=1` — delete each stage's rootfs and rebuild from scratch
  - `SKIP_FULL_IMAGE=true` — build the lite variant only
  - `WLANPI_VERSION` / `WLANPI_CODENAME` — override date-based versioning
- Without `CLEAN=1` the build is **incremental**: it re-runs every sub-stage
  against the existing rootfs under `work/wlanpi-os/<variant>/rootfs/`. Much
  faster, but see the gotcha below.
- Logs: pi-gen writes `work/wlanpi-os/build.log`; a failed run prints a
  Build FAILED banner with timestamps.
- Output lands in `deploy/`: compressed images (`.img.gz`), package manifests
  (`.info`), and checksums.

There is also `build-docker.sh` for containerized builds (used by CI;
`config` auto-detects the container and moves `WORK_DIR` to `/tmp`).

## Verifying the result

Check the manifest for the sideloaded version:

```bash
grep wlanpi-webui deploy/wlanpi-os-*-lite.info
# want the local version, e.g. 1.4.0-2, not the packagecloud 1.4.0-1
```

Or query the work rootfs directly:

```bash
sudo chroot work/wlanpi-os/wlanpi2-full/rootfs \
  dpkg-query -W wlanpi-core wlanpi-common wlanpi-webui wlanpi-fpms
```

## Gotcha: apt "downgrade" errors on incremental rebuilds

Trixie's apt 3.x treats installing a local `.deb` whose version **equals** the
installed version as a downgrade *when the same version also exists in a
configured repo* (the resolver prefers the repo origin, so switching to the
local file counts as a downgrade). On an incremental rebuild the sideloaded
package is already installed, so a plain `apt-get install -y /tmp/<pkg>.deb`
fails with:

```
E: Packages were downgraded and -y was used without --allow-downgrades.
```

All local-deb installs in this repo therefore use
`apt-get install -y --reinstall --allow-downgrades`. `--allow-downgrades`
also guarantees the local deb wins if packagecloud later publishes a higher
(but still Bookworm-built) version. `--reinstall` covers the opposite case: a
deb **rebuilt without a version bump** (same filename, new content). Without
it, an incremental rebuild sees the version already installed in the work
rootfs, reports "already the newest version", and silently keeps the stale
files from the previous build.
