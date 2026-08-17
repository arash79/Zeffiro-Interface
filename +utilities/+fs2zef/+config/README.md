# +utilities/+fs2zef/+config

## Folder purpose

Lookup tables for FreeSurfer→Zeffiro **generators** (compartment names → conductivity/activity/inflate; parcellation scheme IDs). Not the GUI import dialog.

## Main contents

| File | Role |
|------|------|
| `compartment_mappings.m` | Name → σ / activity / inflate defaults |
| `parcellation_schemes.m` | DK `36` / Destrieux `76` scheme metadata |
| `default_config.m` | Used by **`test_unified_pipeline` only** — **`run` does not read it** |

## Code functionality

Generators and tests query these maps when building compartment tables / label schemes. Changing a mapping changes generated project defaults for those pipelines.

## Workflow context

```
fs2zef generators / tests → +config
fs2zef.run → scripts + readers + transforms (does not load default_config)
```

## Usage instructions

```matlab
m = utilities.fs2zef.config.compartment_mappings();
s = utilities.fs2zef.config.parcellation_schemes();
```

## Important notes

- `default_config` is easy to mistake for runtime settings — it is test-oriented.
- Conductivities here are defaults, not patient-specific.

## Developer guidance

- When adding tissues, update mappings and any generator that iterates them.
- Pitfall: editing `default_config` expecting `run` to pick it up.
