function ES_active_electrodes = zef_ES_fix_active_electrodes(zef)
% --- Zeffiro documentation header ---
% zef_ES_fix_active_electrodes — Zef ES fix active electrodes.
%
% Purpose:
%   Zef ES fix active electrodes.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   ES_active_electrodes
%
% Zef fields (observed):
%   zef.ES_score_dose (read)
%   zef.h_ES_fixed_active_electrodes (read)
%   zef.y_ES_interval (read)
%
% Calls (project):
%   zef_ES_fix_active_electrodes
%   zef_ES_objective_function
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[ES_active_electrodes] = zef_ES_fix_active_electrodes(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if not(zef.h_ES_fixed_active_electrodes.Value)
    ES_active_electrodes = [];
else
    try
        [sr, sc] = zef_ES_objective_function(zef);
    catch
        ES_active_electrodes = [];
        return
    end
    
    if isempty(sr)
        ES_active_electrodes = [];
    else
        y_ES_interval = zef.y_ES_interval;
                
        [~,I] = maxk(abs(y_ES_interval.y_ES{sr,sc}), zef.ES_score_dose);
        ES_active_electrodes = sort(I);
    end
end
