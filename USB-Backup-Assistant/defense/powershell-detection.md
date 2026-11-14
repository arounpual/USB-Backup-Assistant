# Detecting Suspicious PowerShell and USB Activity

This guide is for defenders investigating unexpected script execution or file writes to removable media.

## Useful telemetry

| Source | What it can help show | Notes |
|---|---|---|
| Security Event 4688 | Process creation | Command-line capture requires the relevant audit policy to be enabled. |
| Sysmon Event 1 | Process creation and parent/child relationships | Useful for reviewing `wscript.exe` or `cscript.exe` launching PowerShell. |
| Sysmon Event 11 | File creation | Can help identify bursts of files created on a removable volume, depending on configuration. |
| PowerShell Operational Event 4104 | Script block logging | Requires PowerShell logging policy/configuration; availability and content vary by version and policy. |
| Microsoft Defender / EDR alerts | Suspicious script or endpoint behavior | Product capabilities and retention depend on configuration and licensing. |
| Device installation / Plug and Play logs | Device connection context | Event channels and event details vary by Windows build and policy. |

## Investigation ideas

1. Establish whether a removable storage device was connected at the relevant time.
2. Review process creation around that time. Look for script hosts such as `wscript.exe` or `cscript.exe` starting `powershell.exe`.
3. Review the full command line and parent process. A hidden-window argument or execution-policy bypass is a reason to investigate, not proof of compromise by itself.
4. Correlate PowerShell script-block or module logging, if enabled.
5. Review file creation activity on the removable volume and compare it with the user's expected actions.
6. Identify the account, device, time zone, and scope. Preserve relevant logs before cleanup.

## Example hunting questions

- Did a script host launch PowerShell unexpectedly?
- Was PowerShell launched with unusual flags or from an unusual parent process?
- Did a process create many personal-file-like documents on a removable volume in a short period?
- Did the same process write a directory containing network configuration output?
- Was the activity initiated by an authorized user and expected application?

## Important caveats

- `-ExecutionPolicy Bypass` does not automatically mean malware. Execution policy is not a security boundary.
- Hidden-window execution can be used by legitimate administration software too.
- Sysmon only records what its configuration is designed to capture.
- Event IDs and log availability depend on Windows version, audit policy, installed tools, and retention settings.
- A lack of events is not proof that activity did not happen; the relevant logging may not have been enabled.
