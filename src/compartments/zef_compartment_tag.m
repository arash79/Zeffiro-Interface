function compartment_tag = zef_compartment_tag(zef)
% --- Zeffiro documentation header ---
% zef_compartment_tag — Zef compartment tag.
%
% Purpose:
%   Zef compartment tag.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   zef
%
% Outputs:
%   compartment_tag
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%
% Calls (project):
%   zef_compartment_tag
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[compartment_tag] = zef_compartment_tag(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


ismember_tag = 1;
compartment_counter = 0;

while ismember_tag

    compartment_counter = compartment_counter + 1;
    compartment_tag = ['c' num2str(compartment_counter)];
    ismember_tag = ismember(compartment_tag,eval('zef.compartment_tags'));

end

end
