function zef = zef_create_finite_element_mesh(zef)
% --- Zeffiro documentation header ---
% zef_create_finite_element_mesh — Zef create finite element mesh.
%
% Purpose:
%   Zef create finite element mesh.
%   Folder: Sensor lead-field matrices (EEG, MEG, EIT, TES, gravity) and `zef_lead_field_matrix` dispatch on `core.types.ZefSourceModel`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.downsample_surfaces (read, write)
%   zef.n_sources_mod (read, write)
%   zef.source_ind (read, write)
%
% Calls (project):
%   zef_create_fem_mesh
%   zef_create_finite_element_mesh
%   zef_downsample_surfaces
%   zef_postprocess_fem_mesh
%   zef_process_meshes
%   zef_update
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_create_finite_element_mesh(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end 

if zef.downsample_surfaces == 1
    zef = zef_downsample_surfaces(zef);
end
zef = zef_process_meshes(zef);
zef = zef_create_fem_mesh(zef);
zef = zef_postprocess_fem_mesh(zef);
zef.n_sources_mod = 1;
zef.source_ind = [];
zef = zef_update(zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
