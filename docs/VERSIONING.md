# WLAN Pi OS versioning

Format: `YYYY.MM.DD[-type.sequence][.point]-CODENAME`

```
Release version format: YYYY.MM.DD-codename
Point releases: Rare, using YYYY-MM-DD.P-codename format
Codenames: Coffee themed starting with 'Affogato' for releases. Development releases should be using 'theanine' as default codename.
Pre-release markers: -dev, -rc
Dev builds: YYYY.MM.DD-dev.seq-codename
Release candidates: YYYY.MM.DD-rc.seq-codename
Development track: Infrequent
Testing approach: -dev releases until an -rc is cut
Release cadence: Irregular (as needed)
```

Traceability information stored in:

- `/etc/rpi-issue`

Codenames:

- Stored in `/etc/os-release`

Version:

- Stored in `/etc/wlanpi-release`
  
Examples:

```
2025.04.19-dev.1  (First development build on April 4, 2025)
2025.04.19-dev.2  (Second development build on same day)
2025.04.19-rc.1   (First release candidate)
[Testing period of 6 days]
2025.04.19        (Final release promoted on April 10)
2025.04.19.1      (Point/patch/hotfix release if needed)
```

## WLAN Pi OS versioning guidelines

### Version Structure

- Format: YYYY.MM.DD[-type.sequence][.point]
  - YYYY.MM.DD: Base date (e.g., 2025.04.19)
  - -type: Optional pre-release type (-dev or -rc)
  - .seq: Sequential number for same-day builds (1, 2, 3...)
  - .P: Optional point release number for hotfixes (rare)

### Version Types

1. Development builds: `YYYY.MM.DD-dev.seq`
   - For developer testing and feature development
   - Example: 2025.04.19-dev.1

2. Release candidates: `YYYY.MM.DD-rc.seq`
   - For wider testing before final release
   - Example: 2025.04.19-rc.1

3. Final releases: `YYYY.MM.DD`
   - Official stable releases
   - Example: 2025.04.19

4. Point releases: `YYYY.MM.DD.P`
   - For emergency fixes or minor updates same day
   - Example: 2025.04.19.1
