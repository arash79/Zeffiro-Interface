function zef = zef_apply_parameter_profile(zef)
%ZEF_APPLY_PARAMETER_PROFILE  Reload zeffiro_parameters.ini and create missing parameter fields.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Settings → **Parameter profile**. Apply (h_parameter_profile_apply)
%   writecell's the table then calls this. Also from zef_init and
%   zef_add_compartment (new tissue rows get profile σ / extras).
%
%   zef = zef_apply_parameter_profile(zef)
%   zef_apply_parameter_profile          % nargout 0 → assignin base
%
%   Input
%     zef  - session. Omitted → evalin('base','zef').
%
%   Sets zef.parameter_profile from
%   program_path/profile/<profile_name>/zeffiro_parameters.ini (CSV),
%   then zef_init_parameter_profile creates missing zef.<tag>_<name>
%   fields for Segmentation and Sensors rows that are On.
%
%   See also zef_parameter_profile_table_selection, zef_init_parameter_profile.

if nargin == 0
    zef = evalin('base','zef');
end

zef.parameter_profile = eval('readcell([zef.program_path ''/profile/'' zef.profile_name ''/zeffiro_parameters.ini''],''FileType'',''text'',''delimiter'','','');');

zef_init_parameter_profile;

if nargout == 0
    assignin('base','zef',zef);
end

end
