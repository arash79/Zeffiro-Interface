function zef = zef_delete_all_compartments(zef)
%ZEF_DELETE_ALL_COMPARTMENTS  Turn every tissue and sensor set off, then delete them.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not the right-click **Delete compartment(s)** item. Used by
%   zef_start_new_project, which is Project → **New project from profile**
%   and **New empty project** (and import-to-new-project paths).
%
%   zef = zef_delete_all_compartments(zef)
%   zef_delete_all_compartments          % nargout 0 → assignin base
%
%   Input
%     zef  - session. Omitted → evalin('base','zef').
%
%   Output
%     zef  - session after zef_delete_compartment and zef_delete_sensor_sets.
%            If the compartment table Data is empty, zef is unchanged
%            (aside from assignin when nargout is 0).
%
%   Side effects (when the table is non-empty)
%     1. Every compartment-table column 2 **On** cell → 0.
%     2. Every sensors-table column 4 **On** cell → 0.
%     3. zef.compartments_selected = 1:length(compartment_tags);
%        zef_delete_compartment (NaN on those now-inactive rows, zef_update).
%     4. zef.compartments_selected = [].
%     5. zef.sensor_sets_selected = 1:length(sensor_tags);
%        zef_delete_sensor_sets.
%     6. zef.sensor_sets_selected = [].
%
%   See also zef_delete_compartment, zef_start_new_project.

if nargin == 0
    zef = evalin('base','zef');
end

if not(isempty(zef.h_compartment_table.Data))
    for zef_i = 1 : length(zef.h_compartment_table.Data(:,2))
        zef.h_compartment_table.Data{zef_i,2} = 0;
    end
    for zef_i = 1 : length(zef.h_sensors_table.Data(:,4))
        zef.h_sensors_table.Data{zef_i,4} = 0;
    end
    clear zef_i;
    zef.compartments_selected = [1 : length(zef.compartment_tags)];
    zef = zef_delete_compartment(zef);
    zef.compartments_selected = [];
    zef.sensor_sets_selected = [1 : length(zef.sensor_tags)];
    zef = zef_delete_sensor_sets(zef);
    zef.sensor_sets_selected = [];
end

if nargout == 0
    assignin('base','zef',zef);
end


end
