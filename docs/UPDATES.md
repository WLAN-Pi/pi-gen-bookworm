# Update mechanism for A/B partitioned WLAN Pi Go

## Purpose

Create a Python-based system to manage A/B partition updates for embedded Raspberry Pi CM4 devices with 8 GB eMMC storage, supporting both CLI and API interfaces for OS update processes, operating within local network constraints.

## Problem statement

Embedded networking devices need a reliable update mechanism that:

- Minimizes the risk of failed updates making devices unbootable
- Provides a rollback capability if updates cause issues
- Works in constrained environments with limited resources and no Internet access
- Can be triggered manually via CLI or programmatically via API on the local network segment
- File operations must be atomic and provide recovery points.
- Image verification must be performed to determine compatibility with the target hardware.
- Simultaneous updates must be blocked.

## Target users

End users of the WLAN Pi device, such as network professionals, to perform updates on the device to receive software updates, bug fixes, and enhancements on the device.

Software developers integrating update capabilities into WebUI (wlanpi-webui) or mobile apps (WLAN Pi App).

## Key features and components

1. Partition management core

PartitionManager class:

- Identify current partition set (A or B)
- Determine alternate/inactive partition set
- Mount/unmount partitions safely
- Validate partition structure
- Handle PARTUUID mapping and tracking

ConfigManager class:

- Update boot configuration files (cmdline.txt, autoboot.txt, tryboot.txt)
- Handle file system configurations (fstab)
- Manage partition boot preferences

2. Update process components

ImageHandler class:

- Identify partition layouts in images
- Extract and write boot/root partitions
- Stream and decompress OS images
- Verify image compatibility with target hardware
- Check image integrity through checksums

UpdateManager class:

- Orchestrate complete update process
- Validate update prerequisites
- Handle error conditions and rollbacks
- Manage filesystem space requirements
- Report detailed progress during updates

3. Verification components
   
BootValidator class:

- Check current boot status
- Validate partition integrity
- Report boot configuration issues

SystemValidator class:

- Verify system functionality post-update
- Monitor boot success/failure
- Collect diagnostic information

4. Interface layers

CLI interface:

- Command-line tools reimplementing the proof of concept bash scripts functionality
- Progress indicators using standard library
- Interactive confirmation prompts

API interface:

- Synchronous FastAPI endpoints for each operation
- Ensure a lock on the update process and order of operations
- Asynchronous status updates via WebSockets
- Support for WebUI and mobile app integration
- OpenAPI documentation

## Use cases

1. Update alternate partition

- User uploads new OS image via CLI, WebUI, or mobile app.
- System identifies alternate/inactive partition set
- System verifies sufficient space is available on target partitions
- Image is streamed and written to alternate partitions from compressed image
- Configuration is updated for tryboot

2. Verify alternate partition

- System reboots to alternate partition (tryboot)
- Boot status is validated
- System functionality is verified
- User is presented with commit option

3. Commit partition change

- User confirms alternate partition is working (CLI prompt or API call)
- System updates boot configuration
- New partition set becomes the default
- System persists changes across reboots/power cycles

4. Rollback to previous partition

- If new partition fails, automatic revert on next boot
- Manual rollback option available through dedicated API and LCI commands
- System keeps configuration backup for safe recovery

## Persistent storage

- All logs and state tracking will be stored in `/home/<user>/.local/share/wlanpi-core/`
- Upgrade history and status will be maintained in this location
- Configuration backups will be stored here before modifications
- Update metrics and telemetry data stored for system improvement (phase 2)

## Dependencies

Required Python packages

- FastAPI for API endpoints
- Pydantic for data validation
- pytest for testing
- websockets for real-time progress updates (phase 2)
- sh for system command execution (standard library alternatives preferred)

## Hardware/OS requirements

- Raspberry Pi CM4 with 8GB eMMC
- Specific partition layout
  1. p1/p5 for A (boot1/root2)
  2. p2/p6 for B (boot2/root2)
  3. p7 for /home (persistent)
- Raspbian/Raspberry Pi OS based system built off Debian Bookworm using pi-gen
- Local network connectivity (no Internet required)

## Implementation Guidelines

Device validation

- All API endpoints and CLI commands must verify that the device is a WLAN Pi Go model
- Implementation must check /home/.device-info/model and confirm it returns "Go" before processing any operations
- Non-Go devices must receive clear error messages explaining compatibility limitations
- Validation should occur early in the request processing flow to prevent any unnecessary operations
- API endpoints should return HTTP 403 Forbidden with appropriate error details when used on incompatible devices

Filesystem space checking

- Calculate required space for image extraction before beginning update
- Verify both boot and root partitions have sufficient space
- Provide clear error messages if space is insufficient
- Report available space as part of system status

Concurrency and locking

- Implement file-based lock in persistent storage location
- Lock must include timestamp, process ID, and initiator information
- Both CLI and API interfaces must respect the lock
- Provide mechanism to detect and release stale locks
- Allow only one update operation to run at a time

Image compatibility validation

- Verify image format and structure before extraction
- Check image is built for target hardware platform
- Validate image version compatibility with current system
- Prevent installation of incompatible or corrupted images
- Log detailed compatibility information for troubleshooting

Power loss resilience

- Implement atomic file operations where possible
- Create checkpoints during update process
- Store update state information for recovery
- Handle boot-time recovery for interrupted updates
- Resume interrupted updates when possible

Logging

- Use Python's built-in logging module
- Use structured logging with standardized fields
- Store logs in persistent location on /home partition
- Implement log rotation with 10 MB maximum file size
- Track upgrade history and success/failure status
- Create separate log files for updates vs. system operations

Error handling

- Graceful error recovery
- Detailed error reporting
- Prevent unbootable states
- Safe rollback procedures

Security considerations

- Require root/sudo for partition operations
- Validate image integrity
- Prevent unauthorized update triggers

Testing strategy

- Unit tests for all components
- Integration tests for update flows
- Mock tests for partition operations
- Test on actual hardware

Performance considerations

- Streaming decompression for minimal memory usage
- Progress reporting for long-running operations
- Progress for each step in the process (image transfer, update alternate partition, reboot, verification)
- Partition validation
- Support for resource-constrained environments of 1 GB of RAM and 8 GB of eMMC

Local network constraints

- All operations **must** work without Internet access
- Communication limited to local network segment
- Support for WebUI and mobile app via API server on the host 
- File transfers handled over local network protocols

Cross-platform compatibility

- Enable CORS support in FastAPI configuration
- Design WebSocket interface
- Support Chrome apps connecting over local network (10.42.0.1)
- Create platform-agnostic APIs for maximum client compatibility
- Document cross-origin requirements for client applications

OpenAPI documentation 

- Generate comprehensive OpenAPI documentation automatically
- Include request/response schemas, examples, and validation rules
- Document error responses and codes
- Provide usage examples for common operations

WebSocket support

- Implement real-time progress updates via WebSockets
- Support subscribing to specific operation updates
- Provide fallback polling mechanism for clients without WebSocket support
- Include authentication mechanism for WebSocket connections

Progress reporting

- Standardized progress format with:
  - Overall percentage complete
  - Current operation description
  - Time remaining estimate
  - Detailed substep progress
  - Recent log messages
- Event-based progress updates via WebSockets
- Support for operation cancellation when appropriate

Telemetry API

- Collect anonymous system health information
- Hardware status before/after updates
- Performance metrics during updates
- Temperature and resource utilization
- Boot time and system stability metrics

Metrics collection

- Track update success/failure rates
- Measure update duration and resource usage
- Monitor common failure points
- Collect usage patterns to improve user experience
- All metrics must be local-only with no external reporting

Deliverables

- Python package with core functionality
- CLI entry point scripts reimplementing current bash functionality in Python
- FastAPI application with endpoints for all operations
- Documentation for both CLI and API usage
- Test suites for all components
- Update status dashboard

Future enhancements

- Update verification tests
- Improved error recovery
- Image prevalidation

Design inspirations

- Betaflight Configurator
- ESC-Configurator
- Flipper Zero

## Multi-device support

While this implementation specifically targets the WLAN Pi Go device, the system architecture is designed with future extensibility in mind. The following principles should be followed to enable potential multi-device support in later phases.

Abstraction of device-specific elements

- Avoid hardcoding WLAN Pi Go-specific paths or values directly in core logic
- Use configuration-driven approaches where possible
- Isolate device-specific logic in dedicated classes or modules

Partition layout abstraction

- The partition management core should use a configuration-based approach to partition layouts
- Device paths should be stored in configuration rather than hardcoded
- Boot and root partition detection should follow patterns that could be adapted to other layouts

Modular validation

- While initial device validation ensures operation only on WLAN Pi Go devices
- Validation logic should be structured to allow addition of other device types
- System verification should be configurable to adapt to different device capabilities

Code organization

- The `DeviceValidator` class should be designed to be extendable with additional device support
- Core functionality should be separated from Go-specific implementation details
- Public interfaces should be stable to support future device handlers

The system should be designed with flexibility to support multiple device types and partition layouts:

1. Device abstraction layer
   - Abstract device-specific configurations
   - Support different partition layouts
   - Device-specific verification criteria

2. Device detection and configuration
   - Runtime detection of device type
   - Configuration-driven approach
   - Support for custom partition layouts

3. Supported devices
   - Phase 1: WLAN Pi Go (fully tested and supported)

4. Implementation considerations
   - All hardcoded paths will be replaced with configuration-driven paths
   - Device validators will check for compatible partition structures
   - API will include device compatibility information

The goal is to make sure the implementation is specifically designed and tested for the WLAN Pi Go, but with an architecture that will minimize changes needed to support additional device types or partition layouts in the future.

## Recovery scenarios

Key failure modes and recovery strategies:

1. Image corruption during transfer

- Implement checksum verification before extraction
- Retry capability for network transfers
- Clear feedback about corruption location

1. Power loss during partition writing

- Journal write operations where possible
- Record progress checkpoints
- Provide recovery procedure on next boot

3. Network connection failure during API operations

- Timeouts with configurable retry logic
- Status endpoint to check progress after reconnection
- Resume capability for interrupted transfers

4. Unexpected system state after reboot

- Automatic fallback to known-good partition
- Boot validation checks
- Self-healing for common configuration issues

## Image verification strategy

### Phase 1: checksum verification

Initial implementation will use sha256cums to verify image integrity.

- Aims to provide basic protection against corrupted downloads and accidental modifications.
- Each release image has a checksum file (`.sha256`)
- Checksum generation is already integrated into the pi-gen build process
- Checksum verification will be mandatory
- Failed checksum verification will abort the update process with appropriate error messages

Example `ImageHandler` class addition to verify image integrity before processing:

```
def verify_image_checksum(self, image_path, checksum_path=None):
    """Verify image integrity using SHA-256 checksum.
    
    Args:
        image_path: Path to the image file
        checksum_path: Optional path to checksum file, defaults to image_path + .sha256
        
    Returns:
        bool: True if checksum verification passes
    """
```

### Phase 2: signature verification

Once base update mechanism and key management processes are established, enhance to support cryptographic signature verification.

- Use standard signature methods
- Do not implement during phase 1

Example `ImageHandler` class addition to perform signature verification:

```
def verify_image_signature(self, image_path, signature_path=None):
    """Verify image authenticity using cryptographic signature.
    
    Args:
        image_path: Path to the image file
        signature_path: Optional path to signature file, defaults to image_path + .sig
        
    Returns:
        tuple: (verification_success, key_id, error_message)
    """
```

Reasons why signature verification is not considered in phase 1:

- Device is not an internet connected device and isolated from the Internet by default
- Device failure does not lead to physical harm
- Device does not handle or store confidential data
- Device does not have a regulatory requirement like FIPS or Common Criteria
- Device software does not support client mode for the Go and the device is not designed to connect to end user networks
- Device is targeted at network professionals in controlled testing environments
- SHA-256 checksums provide sufficient integrity verification for the current use case
- Limited distribution channels reduce the risk of supply chain attacks
- Updates are performed deliberately by technical users who can verify source authenticity
- Development resources are better allocated to core functionality in phase 1
- The benefit-to-complexity ratio for signature verification doesn't justify implementation in initial release

## System verification

After an update, the system must verify the following to be considered successful:

1. Core system health
   - All essential services (SSH, Networking, API) must start correctly
   - System must boot within expected timeframe (under 60 seconds)

2. Network functionality
   - WLAN interface must exist
   - System must respond to ping on one of the USB OTG interfaces

3. Application functionality
   - WLAN Pi specific applications must start successfully specifically wlanpi-webui and wlanpi-core.

4. Performance verification
   - Memory usage must be below 70% after boot

The system will perform these verifications automatically after booting into
the new partition and report results through both API and CLI interfaces.

## Technical architecture

File Structure

```
partition_manager/
├── core/
│   ├── __init__.py
│   ├── partition_manager.py
│   ├── config_manager.py
│   ├── image_handler.py
│   └── update_manager.py
├── validation/
│   ├── __init__.py
│   ├── boot_validator.py
│   └── system_validator.py
├── interfaces/
│   ├── __init__.py
│   ├── cli.py
│   ├── api.py
│   └── websocket.py
├── utils/
│   ├── __init__.py
│   ├── logging_utils.py
│   ├── system_commands.py
│   ├── locks.py
│   └── metrics.py
├── cli/
│   ├── __init__.py
│   ├── update_partition.py
│   ├── boot_info.py
│   ├── commit_partition.py
│   ├── rollback_partition.py
│   └── tryboot_partition.py
├── tests/
├── pyproject.toml
└── README.md
```

## Detailed Component Specifications

1. PartitionManager Class

Responsibilities:

- Detect current boot configuration (which partition set is active)
- Identify inactive partition set for updates
- Safely mount and unmount partitions
- Get PARTUUID values for configuration updates
- Validate partition structure and integrity

Key functions:

```
def get_current_partition_set()  # Returns 'A' or 'B'
def get_inactive_partition_set()  # Returns the alternate set to current
def get_device_paths()  # Returns paths for all relevant partitions
def get_partition_uuids()  # Gets PARTUUIDs for all partitions
def mount_partition(device, mount_point)  # Safely mounts a partition
def unmount_partition(mount_point)  # Safely unmounts a partition
def is_mounted(device)  # Checks if a partition is mounted
def validate_partition_structure()  # Ensures required partitions exist
def check_available_space(partition)  # Returns available space in bytes
```

2. ConfigManager Class
   
Responsibilities:

- Update boot configuration files
- Modify system configuration files
- Prepare for tryboot testing
- Commit partition changes

Key functions:

```
def update_cmdline_txt(partition, new_root_uuid)  # Update boot parameters
def create_tryboot_txt(target_boot_num)  # Configure for tryboot testing
def update_autoboot_txt(boot_partition)  # Set default boot partition
def update_fstab(partitions)  # Update filesystem mounting
def backup_config(filename)  # Backup configuration before changes
def restore_config(filename)  # Restore from backup if needed
def get_boot_history()  # Get recent boot attempts and status
```

3. ImageHandler Class
   
Responsibilities:

- Analyze OS image structure
- Stream and decompress image files
- Extract and write partitions
- Validate image integrity
- Pre-flight checksums
- Compatibility validation

Key functions:

```
def analyze_image(image_path)  # Determine image partition structure
def extract_boot_partition(image_path, target_device)  # Write boot partition
def extract_root_partition(image_path, target_device)  # Write root partition
def validate_extracted_partitions()  # Verify successful writes
def verify_image_checksum(image_path)  # Verify image integrity
def check_image_compatibility(image_path)  # Check if image works with this hardware
def calculate_space_requirements(image_path)  # Determine space needed for update
```

4. UpdateManager class

Responsibilities:

- Orchestrate the update process
- Track update status
- Handle errors and recovery
- Provide progress information
- Ensure atomic operations

Key functions:

```
def prepare_update(image_path)  # Check prerequisites
def execute_update(image_path)  # Run the update process
def calculate_partition_sizes()  # Ensure partitions have adequate space
def verify_update_success()  # Confirm update worked
def get_update_status()  # Return current status
def get_update_history()  # Return past update attempts
def rollback_update()  # Revert to previous partition state
def create_checkpoint(step)  # Create recovery point during update
def resume_from_checkpoint()  # Resume interrupted update
def report_progress(step, percentage, message)  # Update progress information
```

5. LockManager class

Responsibilities:

- Manage update process locking
- Prevent concurrent updates
- Handle stale locks

Key functions:

```
def acquire_lock(operation, requester)  # Try to acquire lock
def release_lock()  # Release current lock
def get_lock_status()  # Check if lock exists and details
def is_lock_stale()  # Check if existing lock is stale
def force_release_lock()  # Force release a stale lock
```

6. MetricsCollecter class

Responsibilities:

- Collect system performance metrics
- Track update success/failure
- Store telemetry data (phase 2)

Key functions:

```
def record_update_attempt(image_version)  # Record update start
def record_update_result(success, error=None)  # Record update result
def collect_system_metrics()  # Get current system health metrics
def get_update_statistics()  # Return aggregated update statistics
def record_operation_timing(operation, duration)  # Record performance timing
```

7. DeviceValidator class

Responsibilities:

- Verify device is a compatible WLAN Pi Go model
- Check hardware compatibility with update operations
- Provide clear error messaging for incompatible devices

Key functions:

```
def is_go_device()  # Check if device is a WLAN Pi Go model
def get_device_model()  # Return device model string
def validate_device_compatibility()  # Comprehensive compatibility check
def get_compatibility_error()  # Return detailed compatibility error if any
```

8. CLI Scripts
   
update_partition.py:

- Reimplements `update-alternate-partition` in Python
- Takes OS image path as input
- Shows progress during update
- Handles error conditions
- Stores results in persistent location

boot_info.py:

- Reimplements boot-info in Python
- Displays current boot configuration
- Shows partition layout and status
- Identifies which set will boot after power loss

commit_partition.py:

- Reimplements commit-current-partition in Python
- Makes current partition set the default
- Updates boot partition 1's autoboot.txt
- Confirms changes were applied

tryboot_partition.py:

- Reimplements tryboot-alternate-partition in Python
- Configures for temporary boot to alternate set
- Prepares for testing without making permanent changes
- Provides instructions for completing the process

rollback_partition.py:

- Provides manual rollback to previous partition set
- Restores previous configuration
- Confirms rollback success

9. API endpoints

API router-specific middleware:

```
partition_router = APIRouter(prefix="/api/v1/system/partitions")

@partition_router.middleware("http")
async def validate_device_middleware(request: Request, call_next):
    validator = DeviceValidator()
    if not validator.is_go_device():
        return JSONResponse(
            status_code=403,
            content={"detail": "Partition management is only available on WLAN Pi Go devices"}
        )
    return await call_next(request)

@partition_router.get("/info")
async def get_partition_info():
    pass

app.include_router(partition_router)
```

CLI commands should perform validation:

```
def validate_go_device():
    """Validate the current device is a WLAN Pi Go model."""
    validator = DeviceValidator()
    if not validator.is_go_device():
        print("Error: partition management is only available on WLAN Pi Go devices")
        sys.exit(1)
```

In general:

```
GET    /api/v1/system/partitions/info
POST   /api/v1/system/partitions/update
POST   /api/v1/system/partitions/tryboot
POST   /api/v1/system/partitions/commit
POST   /api/v1/system/partitions/rollback
GET    /api/v1/system/partitions/status
GET    /api/v1/system/partitions/history
GET    /api/v1/system/partitions/lock-status
POST   /api/v1/system/partitions/release-lock
GET    /api/v1/system/partitions/metrics
```

GET /api/v1/system/partitions/info:

- Returns current partition configuration
- Provides status of all partitions
- Shows and tracks which partition is active/inactive
- Reports available space on each partition

POST /api/v1/system/partitions/update:

- Accepts OS image upload
- Verifies system has enough free space for image
- Updates inactive partition set
- Returns update progress and status
- Documents instructions for verification

POST /api/v1/system/partitions/tryboot:

- Initiates tryboot to inactive partition
- Triggers reboot with appropriate tryboot instructions
- Documents instructions for verification

POST /api/v1/system/partitions/commit:

- Makes current partition set the default
- Updates boot configuration
- Returns success/failure status

POST /api/v1/system/partitions/rollback:

- Reverts to previous partition configuration
- Returns rollback success/failure status

GET /api/v1/system/partitions/verify:

- Initiates tryboot to inactive partition
- Triggers reboot with appropriate tryboot instructions `sudo reboot '2 tryboot'`
- Documents instructions for verification

GET /api/v1/system/partitions/status:

- Returns current update status with detailed progress information
- Includes overall percentage, current operation, estimated time remaining
- Shows success/failure information
- Reports current step in multi-step operations

GET /api/v1/system/partitions/history:

- Provide chronological record of partition operations
- Provide metrics for update success/failure rates
- Includes id, timestamp, operation, source_image, target_set, status, duration, and details (which vary depending on operation).

GET /api/v1/system/partitions/lock-status

- Check if system is currently updating
- Reports lock details including owner and timestamp

POST /api/v1/system/partitions/release-lock

- Force release a stale lock

GET /api/v1/system/partitions/metrics:

- Returns update success/failure metrics
- Provides performance statistics
- Shows resource utilization during updates

## Phase 2

Telemetry API:

GET /api/v1/system/partitions/telemetry:

- Reports system health information
- Provides hardware status metrics
- Returns boot and partition performance data

WebSocket endpoints

- /api/v1/ws/partitions/updates

The WebSocket connection will:

- Provide real-time progress updates during operations
- Support subscription to specific operations
- Send standardized JSON messages compatible with multiple platforms
- Include authentication similar to REST endpoints
- Fall back gracefully if WebSockets are unavailable
