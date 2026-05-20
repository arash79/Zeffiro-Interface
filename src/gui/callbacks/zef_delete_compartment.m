function zef = zef_delete_compartment(zef,compartments_selected)
% --- Zeffiro documentation header ---
% zef_delete_compartment — Zef delete compartment.
%
% Purpose:
%   Zef delete compartment.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   compartments_selected
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.compartments_selected (read)
%   zef.h_compartment_table (read)
%
% Calls (project):
%   zef_delete_compartment
%   zef_update
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[zef] = zef_delete_compartment(zef, compartments_selected)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
