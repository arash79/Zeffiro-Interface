# Github pusher — MATLAB files (`m/`)

Settings → **Github pusher**. Destructive Git operations on the Zeffiro working copy (push with a PAT, pull, `reset --hard`). User-facing buttons and warnings: [parent README](../README.md).

| File | Role |
|------|------|
| `zef_github_updater_start` | INI callback. Constructs the window and wires Push / Pull / Reset. |
| `zef_github_updater_script` | Reads PAT / author / message widgets, then `zef_git_push`. |
| `zef_git_push` | Rewrites `origin` to `https://sampsapursiainen:<PAT>@github.com/sampsapursiainen/zeffiro_interface`, then `git add -A`, commit, push. The start script’s comment that `./data/` and `./profile/` are ignored is **not** implemented — it stages `-A`. |

Pull/Reset run `!git` in the MATLAB shell (reset is `reset --hard origin` then fetch/pull). There is no dry-run. Do not treat this tool as a substitute for reviewing `git status`.
