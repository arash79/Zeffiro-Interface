# `utilities.dev` — maintainer lint / indent / dependency copy

Not part of mesh, lead field, or inverse. These helpers exist so a developer can indent or lint a tree of `.m` files, or copy the MATLAB files a given entry point needs into a folder (for a stripped bundle). They do not change scientific behaviour.

Run from a MATLAB **desktop** session: `indent_mfile` uses the Editor API (`smartIndentContents` + save). Headless MATLAB has no Editor.

```matlab
utilities.dev.lint_mfiles(projectRoot);           % errors on NODEF / EVLDOT (and codeIssues severity error)
utilities.dev.indent_mfiles(fullfile(projectRoot, "+core"));
utilities.dev.indent_mfile("from_csv.m");         % which() + smartIndentContents + save
msgs = utilities.dev.copy_dependencies_to_folder(entry_mfile, target_folder);
```

`get_mfile_paths(folder)` lists `**/*.m` recursively (used by lint/indent). `lint_mfiles` accepts `"linter_fn_name"` `"codeIssues"` (default, R2022b+), `"checkcode"`, or `"mlint"`. `copy_dependencies_to_folder` uses `matlab.codetools.requiredFilesAndProducts`; optional `folder_whitelist` limits which parents are copied.

Do not run indent over `external/`, generated `zef_start_config.m`, or App Designer `*_exported.m` unless you intend to rewrite those files. Parent utilities map: [`../README.md`](../README.md).
