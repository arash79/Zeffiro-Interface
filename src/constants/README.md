# src/constants

## Folder purpose

Reserved namespace for **shared numerical and structural constants** that should not live as magic numbers inside mesh, forward, or GUI code. The folder is intentionally empty of `.m` files today: user-tunable defaults ship in profile INI files, and many compile-time-like values are still inlined in the routines that use them.

## Main contents

| Item | Status |
|------|--------|
| MATLAB constant modules (`*.m`) | **None** — folder is a reserved path only |
| This `README.md` | Documents the intended contract so maintainers do not invent a second constants home |

Related sources of “constants” elsewhere (do not duplicate blindly):

- `profile/zeffiro_interface.ini` — session / UI / path defaults
- `profile/*/zeffiro_parameters.ini` — physics and inverse parameter profiles
- `src/core/zef_init.m` — field initialization when a key is missing from the project
- `src/core/zef_start_config.m` — warning toggles and external toolbox path hints

## Code functionality

No runtime code executes from this folder. When constants are extracted here in the future, prefer:

- Named functions or simple scripts that return structs (e.g. `zef_fem_stencil_constants`)
- Documented units (SI where possible) and valid ranges
- No GUI handle access and no `eval` of user strings

## Workflow context

Mesh generation (`src/mesh`), lead-field assembly (`src/forward/lead_field`), and barycentric operators (`src/mesh/barycentric`, `src/mesh/operators`) are the primary consumers of numeric stencils and tolerances. Today those values are local to the implementing files; this folder is the planned consolidation point for non-user-overridable numbers.

User-facing knobs must remain in profile INIs so `zef_open_*_profile` and Apply still work.

## Usage instructions

Until `.m` files exist:

```matlab
% Nothing to call. Defaults come from profiles / zef_init, e.g.:
zef = zeffiro_interface;
% then Edit → parameter / system / segmentation profiles in the GUI
```

When adding a constant module, call it explicitly from the consumer (do not rely on `genpath` side effects alone):

```matlab
c = zef_fem_stencil_constants();  % hypothetical
```

## Important notes

- Empty today by design — not a build failure.
- Do not put user-editable SNR, time windows, or conductivity tables here; those belong in profiles / `zef`.
- Do not confuse with `+core` types (`core.types.ZefSourceModel`) or plugin-local parameter structs.
- Stencil and FEM discussion may also appear under `documentation/` TeX notes; keep code and docs in sync if you move numbers here.

## Developer guidance

- Extract magic numbers only when they are shared by ≥2 call sites or need unit tests.
- Prefer one file per domain (`zef_mesh_constants.m`, `zef_forward_tolerances.m`) rather than a single kitchen-sink module.
- Add unit tests under `+tests` if a constant encodes a mathematical identity (e.g. barycentric weight sums).
- Update this README’s Main contents table the same day you add the first `.m` file.
