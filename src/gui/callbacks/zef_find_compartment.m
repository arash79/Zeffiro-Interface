function compartment_tag = zef_find_compartment(property_name,property_value)
% --- Zeffiro documentation header ---
% zef_find_compartment — Zef find compartment.
%
% Purpose:
%   Zef find compartment.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   property_name
%   property_value
%
% Outputs:
%   compartment_tag
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%
% Calls (project):
%   zef_find_compartment
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[compartment_tag] = zef_find_compartment(property_name, property_value)` with project root and `src` on the path.
% --- End Zeffiro documentation header


compartment_tags = evalin('base','zef.compartment_tags');

compartment_tag = '';
compartment_found = 0;
compartment_counter = 0;

if ischar(property_value)
    property_value = ['''' property_value ''''];
else
    property_value = char(string(property_value));
end

while not(compartment_found) && compartment_counter < length(compartment_tags)

    if evalin('base',['isequal(zef.' compartment_tags{end-compartment_counter} '_' property_name ',' property_value ')'])
        compartment_tag = compartment_tags{end-compartment_counter};
        compartment_found = 1;
    end

    compartment_counter = compartment_counter + 1;

end

end
