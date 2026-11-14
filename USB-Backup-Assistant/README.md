# USB Backup Assistant — Data Collection & Defense Lab

A PowerShell-based Windows backup utility and defensive-learning project about removable-media data collection, PowerShell visibility, and endpoint monitoring.

> **Important project history:** The original personal prototype used a VBScript launcher that started PowerShell with a hidden window and did not ask the user for confirmation. The prototype also hid its output folder. This behavior is documented here as a security-learning case study, but it has been deliberately removed from this public edition. The public edition runs visibly, asks the user to select a removable drive, requires explicit confirmation, and does not hide its output.

## What this project demonstrates

- PowerShell automation and Windows removable-drive discovery.
- Selecting and backing up a limited number of recent files.
- Optional collection of non-secret network configuration metadata.
- User consent, visible execution, error handling, and reporting.
- Defensive analysis of suspicious script launch chains and removable-media activity.

## Public-edition features

- Lists removable USB drives and requires the user to choose one; it never silently selects the first drive.
- Requires the user to type `YES` before copying files.
- Copies up to the **20 newest photos**, **10 newest documents**, and **10 newest videos** from the current user's standard Pictures, Documents, and Videos folders.
- Preserves relative subfolder paths to reduce filename collisions.
- Offers a separate opt-in for Wi-Fi profile names, Wi-Fi interface/driver details, and IP configuration.
- Writes a readable `backup-report.txt` with counts and copy errors.
- Runs visibly. It does not hide its process, console, or output folder.

## What changed from the original prototype

| Original prototype | Public educational edition |
|---|---|
| VBS launched PowerShell with a hidden window | Visible `.cmd` launcher and console |
| No confirmation before copying | User selects the USB drive and types `YES` |
| Selected the first detected removable drive | Displays detected drives and asks the user to choose |
| Hid the backup output folder | Output folder remains visible |
| Network inventory was collected automatically | Network inventory is a separate opt-in |
| Failures were not shown interactively | Errors and a completion summary are shown |

The original behavior is described for transparency and defensive study. The public repository intentionally distributes only the visible, consent-based implementation.

## Security and privacy

- No Wi-Fi passwords or keys are collected or exported.
- No browser cookies, sessions, authentication tokens, or other credentials are collected.
- Network inventory is optional. It can contain computer names, MAC addresses, local IP addresses, DNS settings, and saved Wi-Fi network names. Treat these outputs as private; never commit real output to GitHub.
- The backup may copy sensitive personal documents. Run it only on a computer and removable drive you own or are authorized to administer.
- Review the source before running it. Use synthetic files for demonstrations.

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or later
- A writable removable USB drive

## Run

1. Download or clone this repository.
2. Connect a USB drive.
3. Double-click `Run-Backup.cmd`.
4. Select the correct removable drive from the displayed list.
5. Review the destination and type `YES` to proceed.
6. Choose whether to save optional network inventory.

Output is written to `USB-Backup-Assistant/` on the selected USB drive. The folder is not hidden.

You can also run from PowerShell:

```powershell
.\src\USB-Backup.ps1
```

## Output layout

```text
USB-Backup-Assistant/
├── Photos/
├── Documents/
├── Videos/
├── Network-Inventory/       # only when separately approved
│   ├── wifi-profile-names.txt
│   ├── wifi-interfaces.txt
│   ├── wifi-drivers.txt
│   └── ip-configuration.txt
└── backup-report.txt
```

## Defensive-learning material

See the [`defense/`](defense/) directory:

- [Original prototype review](defense/original-prototype-review.md) — what the first version did and why the public version changed.
- [PowerShell detection](defense/powershell-detection.md) — useful Windows event sources and investigation ideas.
- [Windows defenses](defense/windows-defenses.md) — practical controls for removable storage and script execution.
- [Incident response](defense/incident-response.md) — a short response checklist for a suspected unauthorized USB collection event.

See [the architecture diagram](docs/architecture.md) and [security notes](docs/security.md) for implementation details.

## Tests

Run the lightweight repository/source checks from the project root in PowerShell:

```powershell
.\tests\Test-Project.ps1
```

These checks inspect source files; they do not execute a backup or prove runtime behavior. Test with harmless sample files and a spare USB drive before using real data.

## Limitations

- This is a limited backup of selected standard folders, not a full-disk backup.
- Only the newest matching files are selected; hidden folders outside the standard user folders are not searched intentionally.
- Cloud-only files may fail to copy if they are not locally available.
- Network inventory commands depend on Windows networking tools being available.

## License

MIT. See [LICENSE](LICENSE).
