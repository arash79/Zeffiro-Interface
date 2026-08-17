# tools/plugins/GithubPusher/m

## Folder purpose

Developer utility to push local Zeffiro git changes from a small App Designer UI. Not an inverse/forward scientific tool.

## Main contents

| File | Role |
|------|------|
| `zef_github_updater_start.m` | Menu / manual start → open app |
| `zef_github_updater_script.m` | Orchestrate status / commit messaging / push flow |
| `zef_git_push.m` | Low-level git push helper |

App: `../mlapp/zef_github_updater.mlapp`.

## Code functionality

Start opens the updater app; user selects actions that shell out to `git` in the project root (status, commit message fields, push). Requires a configured git remote and credentials/SSH on the machine.

## Workflow context

Optional Multi/Dev tools entry when registered in a profile INI. Unrelated to `zeffiro_downloader.m` (clone/setup).

## Usage instructions

```matlab
zef_github_updater_start;
```

Prefer normal git/CLI or IDE source control for routine work.

## Important notes

- Needs `git` on `PATH` and write access to `.git`.
- Do not commit secrets, patient data, or huge `data/log` dumps via this UI.
- Behavior depends on local branch tracking.

## Developer guidance

- Keep shell commands explicit and logged; never force-push unless the UI makes that impossible.
- Pitfall: using this on a dirty tree with unrelated binary assets.
