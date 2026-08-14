function project_struct = zef_meshing_example_thalamus_refinement
%ZEF_MESHING_EXAMPLE_THALAMUS_REFINEMENT  Mesh with thalamus volume refinement.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   project_struct = zef_meshing_example_thalamus_refinement()
%
%   Imports scripts/scripts_for_importing/multicompartment_head_project/
%   import_segmentation.zef (not the data/segmentations copy). Surface
%   refinement on compartments 18 and 17; volume refinement on 7 (two
%   levels); mesh_resolution 3. Saves data/example_project.mat. No kwargs.
%

project_struct = zeffiro_interface( ...
        'start_mode', 'nodisplay', ...
        'import_to_existing_project', ...
        'scripts/scripts_for_importing/multicompartment_head_project/import_segmentation.zef' ...
    );

    % Meshing parameters: enable smoothing and refinement.
    project_struct.mesh_smoothing_on = 1;
    project_struct.refinement_on = 1;
    project_struct.refinement_surface_on = 1;
    project_struct.refinement_volume_on = 1;

    % Surface refinement: scalp (18) and skull (17) compartments.
    project_struct.refinement_surface_number = [1];
    project_struct.refinement_surface_compartments = [-1 18 17];

    % Volume refinement: thalamus (compartment 7) with 2 refinement levels.
    project_struct.refinement_volume_on_2 = [1];
    project_struct.refinement_volume_compartments_2 = [7];
    project_struct.refinement_volume_number_2 = 2;

    % Mesh resolution (smaller values yield finer meshes).
    project_struct.mesh_resolution = 3;

    % Generate the finite-element mesh.
    project_struct = zef_create_finite_element_mesh(project_struct);

    % Save the project to disk.
    zef_save(project_struct, 'example_project.mat', 'data/');
end
