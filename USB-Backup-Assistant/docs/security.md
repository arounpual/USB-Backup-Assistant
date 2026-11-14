# Security notes

## Data handled by the public edition

| Data | Collected? | Notes |
|---|---:|---|
| Photos | Yes, up to 20 | Newest matching files in Pictures |
| Documents | Yes, up to 10 | Newest matching files in Documents |
| Videos | Yes, up to 10 | Newest matching files in Videos |
| Saved Wi-Fi profile names | Optional | Names only, not keys |
| Wi-Fi adapter/driver details | Optional | Configuration metadata |
| IP configuration | Optional | May include private network identifiers |
| Wi-Fi passwords/keys | No | Explicitly excluded |
| Browser cookies/sessions/tokens | No | Explicitly excluded |

## Safety controls

- The user selects the destination removable drive.
- Copying requires explicit `YES` confirmation.
- Network inventory is a separate opt-in choice.
- The launcher and PowerShell process remain visible.
- The output folder is not hidden.
- No autorun behavior, persistence, obfuscation, or stealth behavior is included.

## Handling reports

Do not publish backup output, network inventory, or real user data. Use synthetic sample data in demonstrations and redact personal identifiers from issue reports.

## Original prototype disclosure

The initial prototype did use a hidden PowerShell window, automatic first-drive selection, no interactive consent, and a hidden output folder. The public edition deliberately removes these behaviors. See [Original Prototype Review](../defense/original-prototype-review.md).
