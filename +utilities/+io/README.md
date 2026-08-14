# `utilities.io` — path, git, and EDF helpers

Small functions used at setup and in study scripts. Not electrode parsers (`core.io.electrodes`) and not project load/save (`src/io`).

| Function | Behaviour |
|----------|-----------|
| `abspath(files)` | Column of **existing** files → absolute paths via `dir`. Each path must pass `mustBeFile`. |
| `float_is_int(x)` | True iff every element is finite and `x == floor(x)` (NaN/Inf → false). |
| `is_eof(token)` | True iff the string is `"-1"` (ASCII sentinel used by some readers). |
| `read_gitmodules(file)` | Parse `.gitmodules` `[submodule "…"]` blocks. Adds `abspath` (relative to the file’s folder) and `name`. Default required keys: `path`, `url`, `branch`, `startupscript` (used by `zeffiro_setup`). |
| `reconstruction_from_edf_fn(path)` | `edfread` (Signal Processing Toolbox). Rows = timetable columns (channels), columns = concatenated cells. Also returns `sample_rate`, `time_step`, `column_title_vec`. |

```matlab
subs = utilities.io.read_gitmodules(fullfile(projectRoot, ".gitmodules"));
[rec, fs, dt, names] = utilities.io.reconstruction_from_edf_fn("recording.edf");
```
