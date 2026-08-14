%ZEF_GITHUB_UPDATER_START  Open Settings → Github pusher.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Default-profile INI callback. Constructs zef_github_updater,
%   title ZEFFIRO Interface: GitHub pusher tool. Default message text
%   and author from zef.user_tag. Push → confirm then
%   zef_github_updater_script. Pull: !git pull. Reset:
%   !git reset --hard origin; !git fetch --all; !git pull.
%
%   See also zef_git_push, zef_github_updater_script.

zef_data = zef_github_updater;
zef_assign_data;
zef.h_github_updater.Name = 'ZEFFIRO Interface: GitHub pusher tool';
zef.h_github_message.Value = 'A regular push adding the changes made in the current local repository to the remote origin. Contents of the folders ./data/ and ./profile/ are ignored. The update necessitates creating a personal access token.';
zef.h_github_author.Value = zef.user_tag;

zef.h_github_updater_button.ButtonPushedFcn = 'if isequal(questdlg(''Push to remote origin?''),''Yes''); zef_github_updater_script; end;';
zef.h_github_reset_button.ButtonPushedFcn = 'if isequal(questdlg(''Reset remote origin?''),''Yes''); eval(''!git reset --hard origin; !git fetch --all; !git pull;''); end;';
zef.h_github_pull_button.ButtonPushedFcn = 'if isequal(questdlg(''Pull from remote origin?''),''Yes'');eval(''!git pull;''); end;';

set(findobj(zef.h_github_updater.Children,'-property','FontSize')
,'FontSize',zef.font_size);

set(zef.h_github_updater,'AutoResizeChildren','off');
zef.github_updater_current_size = get(zef.h_github_updater,'Position');
set(zef.h_github_updater,'SizeChangedFcn','zef.github_updater_current_size = zef_change_size_function(zef.h_github_updater,zef.github_updater_current_size);');
