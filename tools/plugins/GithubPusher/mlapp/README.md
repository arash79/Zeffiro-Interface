# GithubPusher — App Designer layouts

## Folder purpose

App Designer UI for the **GitHub pusher** plugin: a small, destructive Git UI over the Zeffiro working copy (push / pull / reset). Not a general Git client.

## Main contents

| File | Role |
|------|------|
| `zef_github_updater.mlapp` | GitHub pusher tool (PAT, author, message, Push / Pull / Reset) |
| `README.md` | This documentation |

MATLAB logic: `tools/plugins/GithubPusher/m/` (`zef_github_updater_start`, `zef_github_updater_script`, `zef_git_push`).

## Code functionality

`zef_github_updater_start` opens this app and wires **Push** → confirm → `zef_github_updater_script` → `zef_git_push` (rewrites `origin` to upstream with PAT, then pull / `git add -A` / commit / push), **Pull** → `git pull`, **Reset** → `git reset --hard origin` then fetch/pull. Author defaults to `zef.user_tag`; PAT is `zef.h_github_pat`.

## Workflow context

**Settings → Github pusher** (default profile; asteroid: **GitHub pusher**). Callback: `zef_github_updater_start`. Title: **ZEFFIRO Interface: GitHub pusher tool**. Push targets `sampsapursiainen/zeffiro_interface`, not your fork.

## Usage instructions

```matlab
zef_github_updater_start;   % opens zef_github_updater.mlapp
```

1. Open Settings → Github pusher / GitHub pusher.
2. Enter PAT and message; confirm before Push / Pull / Reset.
3. Prefer reviewing `git status` outside this tool before destructive actions.

Edit the layout only in App Designer.

## Important notes

- Push rewrites `origin` with the PAT embedded; not a safe general client.
- Widget text about ignoring `./data/` and `./profile/` is not an exclude list — `git add -A` still runs.
- Reset is hard reset; no dry-run.

## Developer guidance

- Preserve callback `zef_github_updater_start`.
- Keep button handle names (`h_github_updater_button`, `h_github_reset_button`, `h_github_pull_button`) stable with the start script.
- Document destructive remote rewrite clearly in the parent README when changing behavior.
