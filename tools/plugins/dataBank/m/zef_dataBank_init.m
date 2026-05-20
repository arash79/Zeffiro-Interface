function zef = zef_dataBank_init(zef)
% --- Zeffiro documentation header ---
% zef_dataBank_init — Zef data Bank init.
%
% Purpose:
%   Zef data Bank init.
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
%   zef.inv_sampling_frequency (read)
%
% Calls (project):
%   zef_dataBank_init
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_dataBank_init(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef')
end

if not(isfield(zef.dataBank,'var_starttime'))
    zef.dataBank.var_starttime = 0;
end

if not(isfield(zef.dataBank,'var_endtime'))
    zef.dataBank.var_endtime = 0;
end

if not(isfield(zef.dataBank,'workingHashes'))
    zef.dataBank.workingHashes =cell(0);
end


if not(isfield(zef.dataBank,'var_sampling_frequency'))
    zef.dataBank.var_sampling_frequency = zef.inv_sampling_frequency;
end

zef.dataBank.app.StarttimeSpinner.Value = zef.dataBank.var_starttime;
zef.dataBank.app.EndtimeSpinner.Value = zef.dataBank.var_endtime;
zef.dataBank.app.SfreqSpinner.Value = zef.dataBank.var_sampling_frequency;

if nargout == 0
    assignin('base','zef',zef);
end

end
