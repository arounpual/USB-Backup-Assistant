# Architecture

```mermaid
flowchart TD
    A[Run-Backup.cmd] --> B[Visible PowerShell script]
    B --> C[Discover removable drives]
    C --> D[User selects drive]
    D --> E{User types YES?}
    E -- No --> X[Exit without copying]
    E -- Yes --> F[Find newest matching files]
    F --> G[Copy photos, documents and videos]
    G --> H{Network inventory separately approved?}
    H -- No --> J[Write backup report]
    H -- Yes --> I[Save non-secret Wi-Fi and IP metadata]
    I --> J
    J --> K[Show summary]
```

## Main components

- `Run-Backup.cmd`: starts the PowerShell script in a visible console.
- `src/USB-Backup.ps1`: drive selection, confirmation, file discovery, copying, optional network inventory, and reporting.
- `tests/Test-Project.ps1`: repository/source safety checks.
- `defense/`: defensive research notes about the original prototype's behavior and Windows detection/mitigation.
