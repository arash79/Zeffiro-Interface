function subcompartment_ind = zef_compartment_to_subcompartment(zef,compartment_ind)
% --- Zeffiro documentation header ---
% zef_compartment_to_subcompartment — Zef compartment to subcompartment.
%
% Purpose:
%   Zef compartment to subcompartment.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   zef
%   compartment_ind
%
% Outputs:
%   subcompartment_ind
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%
% Calls (project):
%   zef_compartment_to_subcompartment
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[subcompartment_ind] = zef_compartment_to_subcompartment(zef, compartment_ind)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if isempty(zef)
    zef = evalin('base','zef');
end

compartment_tags = eval('zef.compartment_tags');

subcompartment_ind = [];

compartment_counter = 0;
subcompartment_counter = 0;

for i = 1 : length(compartment_tags)

    on_val = eval(['zef.' compartment_tags{i}  '_on']);

    if on_val
        submesh_ind = eval(['zef.' compartment_tags{i} '_submesh_ind']);
        compartment_counter = compartment_counter + 1;
        if ismember(compartment_counter,compartment_ind)
            subcompartment_ind = [subcompartment_ind ; [subcompartment_counter(end) + 1 : subcompartment_counter(end) + length(submesh_ind)]'];
        end
        subcompartment_counter = subcompartment_counter + length(submesh_ind);
    end
end


end
