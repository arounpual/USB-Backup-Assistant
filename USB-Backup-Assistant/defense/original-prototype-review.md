# Original Prototype Review: Why Silent USB Collection Matters

## What the original files did

The first prototype consisted of a PowerShell script and a VBScript launcher. In the submitted launcher, `WScript.Shell.Run` started `powershell.exe` with `-WindowStyle Hidden`, `-ExecutionPolicy Bypass`, and a non-waiting launch. The PowerShell script then:

- Looked for the first removable drive it could find.
- Created an `a_rizo/<computer-name>` destination on that drive.
- Copied up to 20 recent photos, 10 recent documents, and 10 recent videos from the standard user folders.
- Saved Wi-Fi profile names, Wi-Fi interface/driver information, and `ipconfig /all` output.
- Set the backup folder's Hidden attribute.
- Wrote a local report on the USB drive.

The inspected PowerShell source did **not** export saved Wi-Fi passwords or keys. It did collect network metadata that may still be sensitive, such as device names, network names, MAC addresses, and IP configuration.

## Why this is security-relevant

A hidden script launcher, automatic removable-drive selection, file copying without an approval prompt, and concealed output can make data collection difficult for a device owner to notice. These behaviors are useful to study from a defensive perspective because they create observable events across process creation, script execution, file access, and removable storage.

No single indicator proves malicious activity. Administrators should correlate process ancestry, command-line arguments, user context, timing, file writes, device connection events, and the user's expected activity.

## Changes in the public edition

The public edition intentionally removes the silent behavior:

1. It uses a visible command-file launcher.
2. It lists removable drives and asks the user to choose one.
3. It requires the user to type `YES` before file copying.
4. It asks separately before saving network inventory.
5. It keeps the output folder visible.
6. It displays errors and a completion summary.

This repository documents the original prototype accurately, but does not include a silent launcher or a hidden-output mode.

## Safe demonstration idea

Use a Windows virtual machine and synthetic files in a test user profile. Run the visible edition, then review the process and file activity it creates. Separately, use the detection guidance in this repository to understand what defenders could monitor. Do not test on devices or data without authorization.
