# Github pusher

A small Git UI over the Zeffiro working copy: **push**, **pull**, and **reset**. It is **destructive** and it is **not** a general Git client.

`zef_git_push` rewrites `origin` to

```text
https://sampsapursiainen:<PAT>@github.com/sampsapursiainen/zeffiro_interface
```

then `git pull`, `git add -A`, commit, and `git push -u origin`. That remote is the **upstream Zeffiro repository**, not whatever fork you cloned. A push from this tool therefore targets `sampsapursiainen/zeffiro_interface` and leaves your local `origin` URL rewritten with the PAT in it.

The default message widget *says* `./data/` and `./profile/` are ignored. `zef_git_push` still runs `git add -A`; those folders are skipped only if they are already in `.gitignore`. Treat the widget text as a warning, not an implemented exclude list.

Reset is `git reset --hard origin` then fetch/pull. There is no dry-run. Review `git status` yourself before using this window.

## How to open it

**Settings → Github pusher** (default profile; asteroid profiles: **GitHub pusher**). Callback: `zef_github_updater_start` (script). Title: **ZEFFIRO Interface: GitHub pusher tool**.

## Buttons (`ButtonPushedFcn` in `m/zef_github_updater_start.m`)

| Handle | Action |
|--------|--------|
| Push (`h_github_updater_button`) | confirm → `zef_github_updater_script` → `zef_git_push(PAT, 'message', author + ': ' + message)` |
| Reset (`h_github_reset_button`) | confirm → `!git reset --hard origin; !git fetch --all; !git pull;` |
| Pull (`h_github_pull_button`) | confirm → `!git pull;` |

Author field defaults to `zef.user_tag`. PAT is `zef.h_github_pat`.

## Scripting

```matlab
zef_git_push(token, 'message', 'user: message text');
```
