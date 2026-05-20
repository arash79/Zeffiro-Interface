function zef = zef_dataBank_update(zef)
% --- Zeffiro documentation header ---
% zef_dataBank_update — Zef data Bank update.
%
% Purpose:
%   Zef data Bank update.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.dataBank (read)
%
% Calls (project):
%   zef_dataBank_update
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_dataBank_update(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef')
end

zef.dataBank.var_starttime = zef.dataBank.app.StarttimeSpinner.Value;
zef.dataBank.var_endtime = zef.dataBank.app.EndtimeSpinner.Value;
zef.dataBank.var_sampling_frequency = zef.dataBank.app.SfreqSpinner.Value;

if nargout == 0
    assignin('base','zef',zef);
end

end
