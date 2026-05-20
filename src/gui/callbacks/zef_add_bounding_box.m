function zef = zef_add_bounding_box(zef,name_str)
% --- Zeffiro documentation header ---
% zef_add_bounding_box — Zef add bounding box.
%
% Purpose:
%   Zef add bounding box.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   name_str
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.compartment_tags (read, write)
%
% Calls (project):
%   zef_add_bounding_box
%   zef_add_compartment
%   zef_build_compartment_table
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_add_bounding_box(zef, name_str)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

if nargin < 2
    name_str = 'Box';
end

zef = zef_add_compartment(zef);
zef.([zef.compartment_tags{1} '_name']) = name_str;
zef.([zef.compartment_tags{1} '_sources']) = -1;
zef.([zef.compartment_tags{1} '_visible']) = 0;
zef.([zef.compartment_tags{1} '_merge']) = 0;

zef.compartment_tags = [zef.compartment_tags(2:end) zef.compartment_tags(1)];
zef = zef_build_compartment_table(zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
