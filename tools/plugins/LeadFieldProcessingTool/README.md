# LeadFieldProcessingTool

A second lead-field **bank** (`zef.LeadFieldProcessingTool.bank`) with App Designer tables: add the current `L`, replace `zef` from a checked row, mag→grad via a loaded `tra` matrix, and noise-weighted vertical combine.

Default-profile menu label is **LeadFieldProcessingTool** (same callback as asteroid profiles’ “Lead field processing tool”).

## How to open it

**Multi tools → LeadFieldProcessingTool** (default profile). Callback: `LeadFieldProcessingTool_start` (script).

Need a current `zef.L` (and usually sensors / source positions) before **Add**.

## Buttons (`ButtonPushedFcn` in `LeadFieldProcessingTool_start.m`)

| Button | Action |
|--------|--------|
| **Add** | `zef_LeadFieldProcessingTool_addCurrentData2bank` — snapshot `L`, sensors, measurements, noise, interpolation, compartment source flags; new `lead_field_id` |
| **loadTra** | `zef_LeadfieldProcessingTool_loadTra` — load magnetometer→gradiometer `tra` |
| **Mag2Grad** | `zef_LeadfieldProcessingTool_mag2Grad` — `L ← tra*L` on checked rows, `imaging_method = 3`, new bank entry |
| **Replace** | `zef_LeadfieldProcessingTool_aux2current` — copy checked bank row onto live `zef.L`, sensors, measurements, noise, interpolation |
| **Delete** | `zef_LeadfieldProcessingTool_delete` |
| **Combine** | `zef_LeadfieldProcessingTool_combine` — checked rows, each `L` and measurements divided by per-channel std on the noise-start:end samples, then `vertcat`; new bank item |
| **Refresh** | `zef_LeadfieldProcessingTool_refresh` |

Bank table checkbox column (index 6) selects rows. Combine uses **Noisestart** / **Noiseend** spinners.

## Scripting

```matlab
LeadFieldProcessingTool_start;
zef_LeadFieldProcessingTool_addCurrentData2bank;
zef_LeadfieldProcessingTool_aux2current;   % after checking a row
```
