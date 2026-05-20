function zef = zef_apply_parameter_profile(zef)
% --- Zeffiro documentation header ---
% zef_apply_parameter_profile — Zef apply parameter profile.
%
% Purpose:
%   Zef apply parameter profile.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.parameter_profile (read, write)
%   zef.profile_name (read)
%   zef.program_path (read)
%
% Calls (project):
%   zef_apply_parameter_profile
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_apply_parameter_profile(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

zef.parameter_profile = eval('readcell([zef.program_path ''/profile/'' zef.profile_name ''/zeffiro_parameters.ini''],''FileType'',''text'',''delimiter'','','');');

zef_init_parameter_profile;

if nargout == 0
    assignin('base','zef',zef);
end

end
