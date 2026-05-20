function [name_cell, variable_cell] = zef_get_profile_parameters(zef,varargin)
% --- Zeffiro documentation header ---
% zef_get_profile_parameters — Zef get profile parameters.
%
% Purpose:
%   Zef get profile parameters.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   varargin
%
% Outputs:
%   name_cell
%   variable_cell
%
% Zef fields (observed):
%   zef.parameter_profile (read)
%
% Calls (project):
%   zef_get_profile_parameters
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[name_cell, variable_cell]] = zef_get_profile_parameters(zef, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


parameter_index = [];

if not(isempty(varargin))
    parameter_index = varargin{1};
end

parameter_profile = eval('zef.parameter_profile');

zef_n = 0;

for zef_k =  1  : size(parameter_profile,1)
    if ismember(parameter_profile{zef_k,8},{'Segmentation', 'Free-form'}) ...
            && isequal(parameter_profile{zef_k,6},'On') ...
            && isequal(parameter_profile{zef_k,3},'Scalar')
        zef_n = zef_n + 1;
        name_cell{zef_n} = parameter_profile{zef_k,1};
        variable_cell{zef_n} = ['zef.' parameter_profile{zef_k,2}];
    end
end

if not(isempty(parameter_index))
    name_cell = name_cell{parameter_index};
    variable_cell = variable_cell{parameter_index};
end

end
