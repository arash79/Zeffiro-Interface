function zef = zef_set_nse_source_space(zef,nse_field)
% --- Zeffiro documentation header ---
% zef_set_nse_source_space — Zef set nse source space.
%
% Purpose:
%   Zef set nse source space.
%   Folder: Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.
%
% Inputs:
%   zef
%   nse_field
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.source_orientations (read, write)
%   zef.source_positions (read, write)
%
% Calls (project):
%   zef_set_nse_source_space
%   zef_source_interpolation
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_set_nse_source_space(zef, nse_field)` with project root and `src` on the path.
% --- End Zeffiro documentation header


zef.source_positions = nse_field.nodes(nse_field.i_node_ind,:);
zef.source_orientations = [];
zef = zef_source_interpolation(zef);

end
