%ZEF_APPLY_INIT_PROFILE  Eval zeffiro_init.ini rows into zef fields.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Settings → **Pre-settings profile**. Apply (h_init_profile_apply)
%   copies the table into zef.init_profile, writecell's the INI, then
%   runs this script. Also the last step of zef_init.
%
%   Script (not a function). If zef.init_profile is empty, reads
%   program_path/profile/<profile_name>/zeffiro_init.ini. Then
%   zef_init_init_profile evals each row by column-4 type
%   (string / number / evaluate) into zef.<column-3>.
%
%   See also zef_init_init_profile, zef_open_init_profile, zef_init.

if isempty(zef.init_profile)
    zef.init_profile = readcell([zef.program_path '/profile/' zef.profile_name '/zeffiro_init.ini'],'filetype','text','delimiter',',');
end
zef_init_init_profile;
