function [zef] = zef_turn_compartment_onoff(zef,compartment_onoff_vec)
% --- Zeffiro documentation header ---
% zef_turn_compartment_onoff — Zef turn compartment onoff.
%
% Purpose:
%   Zef turn compartment onoff.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   zef
%   compartment_onoff_vec
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%
% Calls (project):
%   zef_turn_compartment_onoff
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_turn_compartment_onoff(zef, compartment_onoff_vec)` with project root and `src` on the path.
% --- End Zeffiro documentation header


c_t = zef.compartment_tags;
n_c_t = length(c_t);

% if isempty(compartment_onoff_vec)
    compartment_onoff_vec = ones(1,n_c_t);
% end

for i = 1 : n_c_t

    zef.([c_t{i} '_on']) = compartment_onoff_vec(i);

end

end
