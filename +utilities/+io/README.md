# +utilities/+io

## Folder purpose

Small **path / file / numeric** helpers used by converters and `zeffiro_setup`. Call as `utilities.io.<name>(...)`. This is **not** project `.mat` save/load (`src/io`) and not electrode parsers (`core.io.electrodes`).

## Main contents

| Function | Role |
|----------|------|
| `float_is_int.m` | `utilities.io.float_is_int(float)` — true iff every finite element equals `floor(element)` |
| `is_eof.m` | `utilities.io.is_eof(in)` — true iff the scalar string is the FreeSurfer ASCII sentinel `"-1"` |
| `read_gitmodules.m` | `utilities.io.read_gitmodules(gitmodules_file)` — parse `.gitmodules` into a struct array |

## Code functionality

### `float_is_int`

Argument: 2-D `double`. Returns `false` if any element is `NaN`, non-finite, or not equal to `floor` of itself. Used by `utilities.fs2zef` ASCII readers before casting node/face counts and connectivity to integers.

### `is_eof`

Argument: scalar `string`. Compares to `"-1"` (FreeSurfer ASCII surfaces/labels terminate counts with that token). Used with `read_ascii_segmentation_file`.

### `read_gitmodules`

```matlab
S = utilities.io.read_gitmodules(fullfile(projectRoot, ".gitmodules"));
% optional:
S = utilities.io.read_gitmodules(path, "required_fields", ["path"; "url"; "branch"]);
```

Reads `[submodule "…"]` headers (path pattern `[\w/]+`) and `key = value` lines. For each block it stores `path`, `url`, `branch`, optional `startupscript`, plus:

- `abspath` — `fullfile(<folder of .gitmodules>, path)`
- `name` — last component of `path` (e.g. `CVX` from `external/CVX`)

Name-value `required_fields` is accepted (`path`, `abspath`, `url`, `branch`, `startupscript`) with default `["path";"url";"branch";"startupscript"]`, but the **function body does not currently enforce** that list. Several `.gitmodules` entries have no `startupscript` (OSQP, SDPT3, SeDuMi, SESAME, spm12). `zeffiro_setup` still indexes `.startupscript` on the struct array; missing keys are empty on a homogeneous struct array.

Empty lines are dropped. A header with no following field lines errors.

## Workflow context

| Caller | Uses |
|--------|------|
| `zeffiro_setup` | `read_gitmodules` to clone + write `zef_start_config.m` |
| `+utilities/+fs2zef/+readers` | `float_is_int`, `is_eof` |

Session persistence remains `src/io`. Submodule layout: `external/README.md`.

## Usage instructions

```matlab
tf = utilities.io.float_is_int([1 2; 3 4]);      % true
tf = utilities.io.float_is_int([1.5 2]);          % false
tf = utilities.io.is_eof("-1");                   % true

S = utilities.io.read_gitmodules( ...
    fullfile(fileparts(which("zeffiro_interface")), ".gitmodules"));
{S.name}'   % CVX, SDPT3, SeDuMi, SESAME, fieldtrip, spm12, OSQP
```

## Important notes

- `float_is_int` rejects `Inf` and `NaN`.
- `is_eof` is a string compare, not `feof` on a file identifier.
- `read_gitmodules` requires the file to exist (`mustBeFile`). Header regex does not match submodule names with hyphens in the `[submodule "…"]` path (current paths are `external/<name>` without hyphens).

## Developer guidance

- Keep this package free of `zef` mutation and GUI dialogs.
- If you add a submodule whose path contains characters other than word chars and `/`, update the header regex and this README together.
- Prefer enforcing `required_fields` in the parser body if you start depending on every key being present; until then, treat `startupscript` as optional.
- Pitfall: using `is_eof` on numeric `-1` (must be `string`).
