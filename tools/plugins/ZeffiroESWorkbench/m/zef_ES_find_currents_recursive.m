function zef = zef_ES_find_currents_recursive(varargin)
%ZEF_ES_FIND_CURRENTS_RECURSIVE  Find currents when HPO search method == 2 (two-stage recursive + fix electrodes).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Find currents button when h_ES_HPO_search_method.Value == 2. Stage 1:
%   uncheck fixed electrodes, zef_ES_recursive_search →
%   adapted_y_ES_interval_1. Stage 2: take the last adapted lattice, check
%   the fixed-electrodes box, zef_ES_fix_active_electrodes, search again →
%   adapted_y_ES_interval_2. Temporary adapted_y_ES is removed.
%
%   zef = zef_ES_find_currents_recursive()
%   zef = zef_ES_find_currents_recursive(zef)
%
%   See also zef_ES_recursive_search, zef_ES_fix_active_electrodes.
%

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
