# Windows Defenses Against Unauthorized USB Data Collection

Use layered controls. Choose settings appropriate to the device owner and organizational policy; overly broad restrictions can interrupt legitimate work.

## Practical controls

### 1. Control removable storage

- In managed environments, use Group Policy or device-control/endpoint-management tools to restrict removable storage to approved users or approved device classes.
- Consider read-only access where users need to read from USB but should not write to it.
- Maintain an approved-device process rather than allowing unknown removable media by default.

### 2. Control script execution

- Use application control such as Windows Defender Application Control (WDAC) or AppLocker where supported and properly managed.
- Prefer signed, reviewed administrative scripts and restrict who can write to script locations.
- Use PowerShell logging and central log collection to improve investigation capability.
- Consider PowerShell Constrained Language Mode in environments where it fits the application-control design.

### 3. Keep endpoint protection active

- Keep Microsoft Defender Antivirus or the organization's endpoint protection platform enabled and updated.
- Review alerts for unusual script interpreters, suspicious process chains, and unexpected writes to removable storage.
- Use attack-surface-reduction and endpoint detection policies appropriate to the organization's environment.

### 4. Improve user and device hygiene

- Do not plug unknown USB devices into sensitive systems.
- Do not run scripts from unknown USB drives.
- Disable or restrict automatic execution features where applicable.
- Use least-privilege accounts for everyday work.
- Encrypt sensitive data stored on removable drives and protect recovery keys.

## What not to rely on alone

- **Execution policy:** it helps govern script execution but is not a security boundary and can be bypassed in some circumstances.
- **Showing hidden files:** useful for manual inspection, but it does not stop a script from reading or copying data.
- **Antivirus alone:** useful but not a substitute for least privilege, application control, logging, and removable-media policy.
