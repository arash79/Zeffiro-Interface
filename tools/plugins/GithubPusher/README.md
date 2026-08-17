## Folder purpose

A small Git UI over the Zeffiro working copy: **push**, **pull**, and **reset**. It is **destructive** and it is **not** a general Git client.

## Main contents

- Start: `m/zef_github_updater_start.m`
- Push helper: `zef_git_push` / `zef_github_updater_script`
- Layout under `mlapp/`

## Code functionality

`zef_git_push` rewrites `origin` to

```text
https://sampsapursiainen:<PAT>@github.com/sampsapursiainen/zeffiro_interface
```

then `git pull`, `git add -A`, commit, and `git push -u origin`. That remote is the **upstream Zeffiro repository**, not whatever fork you cloned. A push from this tool therefore targets `sampsapursiainen/zeffiro_interface` and leaves your local `origin` URL rewritten with the PAT in it.

The default message widget *says* `./data/` and `./profile/` are ignored. `zef_git_push` still runs `git add -A`; those folders are skipped only if they are already in `.gitignore`. Treat the widget text as a warning, not an implemented exclude list.

Reset is `git reset --hard origin` then fetch/pull. There is no dry-run. Review `git status` yourself before using this window.

Buttons (`ButtonPushedFcn` in `m/zef_github_updater_start.m`):

| Handle | Action |
|--------|--------|
| Push (`h_github_updater_button`) | confirm → `zef_github_updater_script` → `zef_git_push(PAT, 'message', author + ': ' + message)` |
| Reset (`h_github_reset_button`) | confirm → `!git reset --hard origin; !git fetch --all; !git pull;` |
| Pull (`h_github_pull_button`) | confirm → `!git pull;` |

Author field defaults to `zef.user_tag`. PAT is `zef.h_github_pat`.

## Workflow context

**Settings → Github pusher** (default profile; asteroid profiles: **GitHub pusher**). Callback: `zef_github_updater_start` (script). Title: **ZEFFIRO Interface: GitHub pusher tool**.

## Usage instructions

```matlab
zef_git_push(token, 'message', 'user: message text');
```

1. Open Settings → Github pusher / GitHub pusher.
2. Enter PAT and message; confirm before Push / Pull / Reset.
3. Prefer reviewing `git status` outside this tool before destructive actions.

## Important notes

- Push rewrites `origin` to upstream with PAT embedded; not your fork.
- Widget text about ignoring `./data/` and `./profile/` is not an exclude list — `git add -A` still runs.
- Reset is hard reset to origin; no dry-run.

## Developer guidance

Preserve callback `zef_github_updater_start`. Document destructive remote rewrite and `git add -A` behavior clearly; do not present this as a safe general Git client.
