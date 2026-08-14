function zef_git_push(my_key,varargin)
%ZEF_GIT_PUSH  git add/commit/push using a PAT as the remote password.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_git_push(my_key)
%   zef_git_push(my_key, 'message', commit_message)
%
%   Called from zef_github_updater_script. Rewrites origin to
%   https://sampsapursiainen:KEY@github.com/sampsapursiainen/
%   zeffiro_interface then !git add -A, commit, push. Side effects:
%   git and the remote URL. Default message 'Regular push.'
%
%   See also zef_github_updater_start.

message = '"Regular push."';

if not(isempty(varargin))
    zef_i = 1;
    while zef_i <= length(varargin)
        aux_var = varargin {zef_i + 1};
        if isequal(varargin {zef_i},'message')
            aux_var = char(join(string(aux_var)));
        end
        eval([varargin{zef_i} '= ''' aux_var ''';']);
        zef_i = zef_i + 2;
    end
end

eval(['!git remote set-url origin https://sampsapursiainen:' my_key '@github.com/sampsapursiainen/zeffiro_interface'])
;

% Same set-url twice (as written). Origin becomes the upstream Zeffiro
% repo with the PAT in the URL; this is not your clone's previous remote.
eval(['!git remote set-url origin https://sampsapursiainen:' my_key '@github.com/sampsapursiainen/zeffiro_interface'])
!git config http.postBuffer 524288000
!git pull
!git add -A
eval(['!git commit -m "' message '"']);
!git push -u origin

end
