# WLAN Pi OS versioning

Format: `YYYY.MM.DD[-type.sequence][.point]-CODENAME`

```
Release version format: YY.MM-codename
Point releases: Rare, using YY.MM.P-codename format
Codenames: Coffee themed starting with 'Affogato' for releases. Development releases should be using 'theanine' as default codename.
Pre-release markers: -dev, -rc
Dev builds: YY.MM-dev.seq-codename
Release candidates: YY.MM-rc.seq-codename
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
25.07-dev.1-theanine  (First development build in April 2025)
25.07-dev.2-theanine  (Second development build same month)
25.07-rc.1-theanine   (First release candidate)
[Testing period]
25.07-theanine        (Final release)
25.07.1-theanine      (Point/patch/hotfix release if needed)
```

## WLAN Pi OS versioning guidelines

### Version Structure

- Format: YY.MM.DD[-type.sequence][.point]
  - YY.MM.DD: Base date (e.g., 25.07.19)
  - -type: Optional pre-release type (-dev or -rc)
  - .seq: Sequential number for same-day builds (1, 2, 3...)
  - .P: Optional patch release number for hotfixes (rare)

### Version Types

1. Development builds: `YY.MM-dev.seq`
   - For developer testing and feature development
   - Example: 25.07.19-dev.1

2. Release candidates: `YY.MM-rc.seq`
   - For wider testing before final release
   - Example: 25.07.19-rc.1

3. Final releases: `YY.MM`
   - Official stable releases
   - Example: 25.07

4. Patch releases: `YYYY.MM.P`
   - For emergency fixes or minor updates same day
   - Example: 25.07.1
