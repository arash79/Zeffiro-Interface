function project_struct = zef_meshing_example_thalamus_refinement
% --- Zeffiro documentation header ---
% examples.meshing.project_struct — Example or study script demonstrating project_struct.
%
% Purpose:
%   Example or study script demonstrating project_struct.
%   Folder: Runnable examples and study scripts that exercise meshing, forward lead fields, inverse solvers, importing, and published workflows.
%
% Calls (project):
%   zef_create_finite_element_mesh
%   zef_meshing_example_thalamus_refinement
%   zef_save
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `examples.meshing.project_struct` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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
