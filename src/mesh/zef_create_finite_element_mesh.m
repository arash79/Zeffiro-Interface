function zef = zef_create_finite_element_mesh(zef)
%ZEF_CREATE_FINITE_ELEMENT_MESH  Mesh-tool wrapper: downsample, volume mesh, postprocess.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   This is what the Mesh tool button "Create FEM mesh" (h_pushbutton21)
%   runs. It is the full user-facing mesh pipeline, not the lattice
%   builder itself:
%
%     if zef.downsample_surfaces == 1
%         zef_downsample_surfaces
%     zef_process_meshes      % surfaces → zef.reuna_p / reuna_t
%     zef_create_fem_mesh     % lattice, label, refine → nodes/tetra
%     zef_postprocess_fem_mesh
%     clear source index cache; rebuild the sensors table from zef; zef_update
%     (zef_update copies mesh-tool fields onto widgets; it does not read them)
%
%   After this, sensors still need attaching and a lead field still needs
%   assembling (Mesh tool forward-simulation table / Run script, or
%   zef_eeg_make_all and the other modality wrappers).
%
%   zef = zef_create_finite_element_mesh(zef)
%
%   Input / output
%     zef  - session struct. If omitted, read from the base workspace.
%            If nargout is 0, assigned back to base.
%
%   See also zef_create_fem_mesh, zef_process_meshes, zef_postprocess_fem_mesh,
%            zef_mesh_tool, zef_run_forward_simulation, zef_eeg_make_all.

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
% The sensors table is a view. Rebuild it from zef before zef_update so a
% startup row is not written onto the loaded set.
zef = zef_build_sensors_table(zef);
zef = zef_update(zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
