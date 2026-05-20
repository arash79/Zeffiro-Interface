function project_struct = zef_meshing_example_thalamus_refinement
%
% examples.zef_meshing_example_thalamus_refinement
%
% Demonstrates finite-element mesh generation with thalamic volume refinement.
% This example extends the standard meshing workflow by enabling both surface
% refinement (scalp and skull compartments) and volume refinement specifically
% targeting the thalamus (compartment 7). Useful for studies requiring higher
% spatial resolution in subcortical structures.
%
% The script:
%   1. Loads a multi-compartment head segmentation
%   2. Enables surface refinement for scalp (18) and skull (17)
%   3. Enables volume refinement for thalamus (7) with 2 refinement levels
%   4. Generates the FEM mesh and saves the result
%
% Returns:
%   project_struct  Struct containing the generated mesh (also saved to file)
%
% See also: examples.zef_meshing_example, zef_create_finite_element_mesh
%

    % Initialize Zeffiro Interface with the multi-compartment head project.
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
