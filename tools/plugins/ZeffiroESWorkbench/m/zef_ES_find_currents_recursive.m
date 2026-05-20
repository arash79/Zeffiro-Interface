function zef = zef_ES_find_currents_recursive(varargin)
% --- Zeffiro documentation header ---
% zef_ES_find_currents_recursive — Zef ES find currents recursive.
%
% Purpose:
%   Zef ES find currents recursive.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   varargin
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.ES_HPO_recursive_instances (read)
%   zef.ES_active_electrodes (read, write)
%   zef.ES_step_size (read)
%   zef.adapted_y_ES (read)
%   zef.adapted_y_ES_interval_1 (read, write)
%   zef.adapted_y_ES_interval_2 (read, write)
%   zef.h_ES_fixed_active_electrodes (read)
%   zef.y_ES_interval (read, write)
%
% Calls (project):
%   zef_ES_find_currents_recursive
%   zef_ES_fix_active_electrodes
%   zef_ES_recursive_search
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_ES_find_currents_recursive(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header

switch nargin
case {0,1}
if nargin == 0
zef = evalin('base','zef');
else
zef = varargin{1};
end

% UnFixing Electrodes
zef.h_ES_fixed_active_electrodes.Value = 0;
zef_ES_optimization_update;
zef.ES_active_electrodes    = zef_ES_fix_active_electrodes(zef);

% 1st stage
zef                         = zef_ES_recursive_search(zef, zef.ES_step_size, zef.ES_HPO_recursive_instances);
zef.adapted_y_ES_interval_1 = zef.adapted_y_ES;

% Fixing Electrodes
zef.y_ES_interval           = zef.adapted_y_ES_interval_1{end};

zef.h_ES_fixed_active_electrodes.Value = 1;
zef_ES_optimization_update;
zef.ES_active_electrodes    = zef_ES_fix_active_electrodes(zef);

% 2nd stage
zef.y_ES_interval           = zef.adapted_y_ES_interval_1{1};

zef                         = zef_ES_recursive_search(zef, zef.ES_step_size, zef.ES_HPO_recursive_instances);
zef.adapted_y_ES_interval_2 = zef.adapted_y_ES;


zef = rmfield(zef, 'adapted_y_ES');

if nargout == 0
assignin('caller','zef',zef);
end

end
