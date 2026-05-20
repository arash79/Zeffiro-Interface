%Copyright © 2018- Joonas Lahtinen, Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface

%function for changing time serie parameters temporarly for GMM visualization
%Input char 'in' means replacing inv_... parameters with the ones saved to
%GMM structure and 'out' changes them back. parameter are temporarly placed
%on workspace with names like zef_temp_time_1

function zef_GMM_subs_time_vars(char_var)
% --- Zeffiro documentation header ---
% zef_GMM_subs_time_vars — Zef GMM subs time vars.
%
% Purpose:
%   Zef GMM subs time vars.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   char_var
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.GMM (read)
%   zef.inv_sampling_frequency (read, write)
%   zef.inv_time_1 (read, write)
%   zef.inv_time_2 (read, write)
%   zef.inv_time_3 (read, write)
%
% Calls (project):
%   zef_GMM_subs_time_vars
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_GMM_subs_time_vars(char_var)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if evalin('base','isfield(zef.GMM,''time_variables'')')
    if evalin('base','~isempty(zef.GMM.time_variables)')
        if strcmp(char_var,'in')
            if evalin('base','isfield(zef.GMM.time_variables,''time_1'')')
                evalin('base','zef_temp_time_1 = zef.inv_time_1;');
                evalin('base','zef.inv_time_1 = zef.GMM.time_variables.time_1;');
            end
            if evalin('base','isfield(zef.GMM.time_variables,''time_2'')')
                evalin('base','zef_temp_time_2 = zef.inv_time_2;');
                evalin('base','zef.inv_time_2 = zef.GMM.time_variables.time_2;');
            end
            if evalin('base','isfield(zef.GMM.time_variables,''time_3'')')
                evalin('base','zef_temp_time_3 = zef.inv_time_3;');
                evalin('base','zef.inv_time_3 = zef.GMM.time_variables.time_3;');
            end
            if evalin('base','isfield(zef.GMM.time_variables,''sampling_frequency'')')
                evalin('base','zef_temp_sampling_frequency = zef.inv_sampling_frequency;');
                evalin('base','zef.inv_sampling_frequency = zef.GMM.time_variables.sampling_frequency;');
            end
        elseif strcmp(char_var,'out')
            if evalin('base','isfield(zef.GMM.time_variables,''time_1'')')
                evalin('base','zef.inv_time_1 = zef_temp_time_1; clear zef_temp_time_1;');
            end
            if evalin('base','isfield(zef.GMM.time_variables,''time_2'')')
                evalin('base','zef.inv_time_2 = zef_temp_time_2; clear zef_temp_time_2;');
            end
            if evalin('base','isfield(zef.GMM.time_variables,''time_3'')')
                evalin('base','zef.inv_time_3 = zef_temp_time_3; clear zef_temp_time_2;');
            end
            if evalin('base','isfield(zef.GMM.time_variables,''sampling_frequency'')')
                evalin('base','zef.inv_sampling_frequency = zef_temp_sampling_frequency; clear zef_temp_sampling_frequency;');
            end
        end
    end
end

end
