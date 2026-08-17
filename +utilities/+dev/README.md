# `utilities.dev` — maintainer lint / indent / dependency copy

## Folder purpose

Not part of mesh, lead field, or inverse. Helpers so a developer can indent or lint a tree of `.m` files, or copy the MATLAB files a given entry point needs into a folder (for a stripped bundle). They do not change scientific behaviour.

## Main contents

| Function | Role |
|----------|------|
| `lint_mfiles` | Lint a tree; errors on NODEF / EVLDOT (and `codeIssues` severity error) |
| `indent_mfiles` / `indent_mfile` | Editor smart-indent + save |
| `get_mfile_paths` | Recursive `**/*.m` listing |
| `copy_dependencies_to_folder` | `matlab.codetools.requiredFilesAndProducts` → copy |

## Code functionality

`lint_mfiles` accepts `"linter_fn_name"` `"codeIssues"` (default, R2022b+), `"checkcode"`, or `"mlint"`. `indent_mfile` uses the Editor API (`smartIndentContents` + save). `copy_dependencies_to_folder` optionally takes `folder_whitelist` to limit which parents are copied. `get_mfile_paths(folder)` feeds lint/indent.

## Workflow context

Maintainer tooling only. Parent utilities map: `+utilities/README.md`.

## Usage instructions

Run from a MATLAB **desktop** session (`indent_mfile` needs the Editor API; headless MATLAB has no Editor):

```matlab
utilities.dev.lint_mfiles(projectRoot);
utilities.dev.indent_mfiles(fullfile(projectRoot, "+core"));
utilities.dev.indent_mfile("from_csv.m");
msgs = utilities.dev.copy_dependencies_to_folder(entry_mfile, target_folder);
```

## Important notes

Do not run indent over `external/`, generated `zef_start_config.m`, or App Designer `*_exported.m` unless you intend to rewrite those files.

## Developer guidance

Prefer scoped indent/lint (e.g. `+core`) over whole-repo rewrites. Keep whitelist usage when bundling dependencies so vendor trees stay out of stripped copies.
