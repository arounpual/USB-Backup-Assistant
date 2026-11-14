# Incident Response: Suspected Unauthorized USB Collection

Use this checklist when a computer may have copied files to an unknown or unexpected USB device.

1. **Contain carefully.** If activity appears ongoing, disconnect the removable drive if safe to do so and follow your organization's incident procedure. Avoid actions that destroy evidence.
2. **Record context.** Note the computer, logged-in account, approximate time, USB device details, and what the user observed.
3. **Preserve evidence.** Retain relevant endpoint alerts, process-creation events, PowerShell logs, device-connection records, and file-system evidence according to policy.
4. **Identify scope.** Determine which files and network metadata may have been accessed or copied. Do not assume that all files on the computer were collected.
5. **Assess exposure.** If sensitive information may have left the device, notify the appropriate security/privacy team and follow applicable reporting requirements.
6. **Eradicate and recover.** Remove unauthorized scripts or launchers only after evidence preservation and approval. Scan the endpoint, review persistence locations, and restore normal device-control settings.
7. **Prevent recurrence.** Apply least privilege, removable-storage restrictions, application control, PowerShell logging, and user awareness improvements.

Do not insert an unknown USB drive into another production computer to inspect it. Use an isolated forensic workstation and established evidence-handling procedures when investigation is required.
