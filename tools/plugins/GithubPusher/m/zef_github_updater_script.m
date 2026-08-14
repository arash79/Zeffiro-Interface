%ZEF_GITHUB_UPDATER_SCRIPT  Push via zef_git_push using the window PAT and message.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Called from the Push button after a confirm dialog.
%   zef_git_push(h_github_pat.Value, 'message', author + ': ' +
%   join(h_github_message.Value)). Side effects: git add/commit/push
%   and rewriting origin (see zef_git_push).
%
%   See also zef_git_push, zef_github_updater_start.

zef_git_push(zef.h_github_pat.Value,'message',[zef.h_github_author.Value  ': ' char(join(string(zef.h_github_message.Value)
))]);
