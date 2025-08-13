# Patch Management & Full Maintenance Playbook Documentation

## Overview

This project delivers a robust, enterprise-grade Ansible automation framework designed for efficient **patch management** and **operating system hardening** across heterogeneous server environments. It aims to:

    * Apply security and general OS patches reliably across multiple distributions.
    * Harden systems by securing SSH, kernel parameters, and disabling legacy services.
    * Automate reboot handling post-patching where necessary.
    * Validate critical services and maintain detailed audit logging.
    * Provide reusable, modular roles for easy customization and extensibility.
    * Support multiple environments (development, staging, production) via inventory segregation.

## Patch Management Role

### Purpose

The `patch_management` role is designed to automate the process of keeping Linux servers updated securely and consistently by applying patches, detecting the need for a system reboot, and optionally triggering a reboot.


### Supported Platforms

* Debian-based systems (Ubuntu, Debian)
* RedHat-based systems (RHEL, CentOS, Amazon Linux)


### Features

    * Selective patching: Option to install only security updates or all available patches.
    * Package exclusions: Ability to exclude specific packages from patching to avoid conflicts.
    * Reboot detection: Determines if a reboot is required based on OS-specific signals.
    * Reboot automation: Optional automatic reboot based on configurable flags.
    * Cross-platform compatibility: Uses `apt` for Debian systems and `yum` for RedHat systems.


### Role Variables

| Variable                   | Description                                         | Default           |
| -------------------------- | --------------------------------------------------- | ----------------- |
| `patch_security_only`      | If true, only security patches are installed        | `false`           |
| `patch_reboot_if_needed`   | If true, system will reboot if patching requires it | `false`           |
| `patch_package_exclusions` | List of packages to exclude from patching           | `[]` (empty list) |


### How It Works

* Updates the package cache according to the OS.
* Installs patches based on the `patch_security_only` flag.
* Checks for a reboot requirement using OS-specific methods:

  * For Debian/Ubuntu: Checks the existence of `/var/run/reboot-required`.
  * For RedHat-based: Uses the `needs-restarting -r` command.
* Sets a fact `reboot_required` that downstream playbooks can use.
* Optionally triggers a reboot if `patch_reboot_if_needed` is true and reboot is required.


### Example Task Flow (Summary)

1. Refresh package cache.
2. Apply patches (security-only or all).
3. Detect if reboot is required.
4. Set a reboot flag for the playbook.
5. Optionally reboot the server.


## OS Hardening Role

* Secures SSH configurations (disable root login, password auth).
* Disables legacy and vulnerable services (telnet, rsh, rexec).
* Applies sysctl kernel parameter tuning for security hardening.
* Configures SSH banners for compliance and auditing.


## Full Maintenance Playbook

### Purpose

The `full-maintenance.yml` playbook orchestrates a complete maintenance cycle across all hosts. It sequentially runs:

1. Patch management with reboot detection.
2. OS hardening to secure system settings.
3. Automatic reboot if required.
4. Post-maintenance verification of critical services such as SSH.
5. Audit log appending to maintain an operational history.


### Playbook Structure

* **Hosts**: Runs on all targeted servers.
* **Privileges**: Uses privilege escalation (`become: true`) for system-level changes.
* **Pre-tasks**: Announces the start of the maintenance window.
* **Roles**:

  * `patch_management` with parameters controlling patching behavior and reboot.
  * `os_hardening` with parameters controlling security hardening settings.
* **Post-tasks**:

  * Validate SSH service status.
  * Log maintenance completion with timestamps.


### Example Run

```bash
ansible-playbook -i inventories/production/hosts.ini playbooks/full-maintenance.yml
```

### Variables Example for Full Maintenance

```yaml
patch_security_only: true
patch_reboot_if_needed: true
patch_package_exclusions: []

harden_ssh: true
harden_sysctl: true
harden_services: true
disable_services:
  - telnet
  - rsh
  - rexec
ssh_banner_text: |
  Authorized use only. All activity is monitored.
ssh_permit_root_login: "no"
ssh_password_authentication: "no"
ssh_max_auth_tries: 3
ssh_login_grace_time: 30
sysctl_params:
  net.ipv4.ip_forward: 0
  net.ipv4.conf.all.accept_redirects: 0
  net.ipv4.conf.all.send_redirects: 0
```

## Inventory Structure

The project supports multiple environment inventories for separation of development, staging, and production, allowing safe testing before production rollout. Group variables define environment-specific settings such as:

* SSH users and keys
* Patch exclusions
* Hardening parameters

## Logging and Auditing

Post-maintenance logs are appended to:

```
/var/log/infra-secure-maintenance/maintenance.log
```

This enables auditing for compliance and troubleshooting.

## Testing Recommendations

1. **Local VM or Lab Setup**: Use virtual machines with matching OS distributions to your production.
2. **Cloud Environment**: Use AWS EC2 or equivalent to replicate real-world infrastructure.
3. **Stepwise Testing**:

   * Run patch management independently and verify patch application and reboot detection.
   * Apply OS hardening separately and verify system configurations.
   * Run full maintenance and monitor reboot and SSH availability.
4. **Backups and Rollbacks**: Implement inventory-specific rollback playbooks or snapshots before running maintenance.

## Extensibility & Contribution

* Extend patch management to support other package managers (e.g., `dnf`, `zypper`).
* Add more granular hardening modules for specific compliance standards (CIS, NIST).
* Integrate monitoring and alerting hooks post-maintenance.
* Customize reboot policies (scheduled reboots, notification systems).

## Security Considerations

* Always ensure SSH key and user permissions are configured correctly to avoid lockouts.
* Apply patching during approved maintenance windows.
* Test hardening parameters on non-production systems to prevent service disruptions.
* Maintain audit logs securely and regularly review them.