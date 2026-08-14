function zef = zef_delete_compartment(zef,compartments_selected)
%ZEF_DELETE_COMPARTMENT  Drop selected *inactive* compartment table rows.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Right-click the Segmentation compartment table → **Delete compartment(s)**.
%   zef_menu_tool sets MenuSelectedFcn to
%   "zef_delete_compartment;zef_init_sensors_parameter_profile;".
%
%   Rows come from zef.compartments_selected (set by
%   zef_compartment_table_selection) unless you pass compartments_selected.
%   Only rows with column 2 **On** false are flagged: column 1 (Index) is
%   set to NaN. zef_update then removes those tags and their zef.<tag>_*
%   fields. Active (On) rows are left alone — turn On off first, then delete.
%
%   zef_start_new_project uses zef_delete_all_compartments, which calls this
%   after turning compartments off.
%
%   zef = zef_delete_compartment(zef)
%   zef = zef_delete_compartment(zef, row_indices)
%
%   Inputs
%     zef                    - session. Omitted → base workspace.
%     compartments_selected  - 1-based table row indices. Default
%                              zef.compartments_selected; empty uses that field.
%
%   See also zef_add_compartment, zef_update, zef_delete_all_compartments.

if nargin < 2
    compartments_selected = [];
end

if nargin == 0
    zef = evalin('base','zef');
end

table_data = zef.h_compartment_table.Data;

if isempty(compartments_selected)
compartments_selected =  zef.compartments_selected;
end

for i = 1 : length(compartments_selected)
    if not(table_data{compartments_selected(i),2})
       zef.h_compartment_table.Data{compartments_selected(i),1} = NaN;
    end
end

zef = zef_update(zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
