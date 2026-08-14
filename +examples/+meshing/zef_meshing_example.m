%Copyright (c) 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function project_struct = zef_meshing_example ( kwargs )
%ZEF_MESHING_EXAMPLE  Nodisplay FEM mesh from the bundled head segmentation.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   project_struct = zef_meshing_example(kwargs)
%
%   Requires data/segmentations/multicompartment_head_project/import_segmentation.zef
%   (or kwargs.input_project_path). Starts zeffiro_interface with
%   import_to_existing_project, copy_fields of meshing kwargs, then
%   zef_create_finite_element_mesh and zef_save to data/meshing_example.mat
%   (output_project_dir / output_project_file). Default mesh_resolution 4.5.
%

arguments
    kwargs.start_mode = "nodisplay"
    kwargs.input_project_path (1,1) string { mustBeFile } = fullfile ( "data", "segmentations", "multicompartment_head_project", "import_segmentation.zef" )
    kwargs.output_project_dir (1,:) char { mustBeFolder } = "data"
    kwargs.output_project_file (1,:) char = "meshing_example.mat"
    kwargs.use_gpu (1,1) logical = true;
    kwargs.adaptive_refinement_compartments (1,:) double { mustBeInteger } = -1
    kwargs.adaptive_refinement_k_param (1,1) double { mustBePositive, mustBeInteger } = 5
    kwargs.adaptive_refinement_number (1,:) double { mustBeInteger } = 1
    kwargs.adaptive_refinement_on (1,1) logical = false
    kwargs.adaptive_refinement_thresh_val (1,1) double { mustBePositive } = 2
    kwargs.exclude_box (1,1) logical = true
    kwargs.fem_mesh_inflation_strength (1,1) double { mustBeNonnegative } = 0.05
    kwargs.fix_outer_surface (1,1) logical = true
    kwargs.initial_mesh_mode (1,1) double { mustBeMember (kwargs.initial_mesh_mode, [1, 2]) } = 1
    kwargs.mesh_labeling_approach (1,1) double { mustBeMember (kwargs.mesh_labeling_approach, [1, 2]) } = 1
    kwargs.mesh_optimization_parameter (1,1) double { mustBePositive } = 1e-5
    kwargs.mesh_optimization_repetitions (1,1) double { mustBeNonnegative, mustBeInteger } = 10
    kwargs.mesh_relabeling (1,1) logical = true
    kwargs.mesh_resolution (1,1) double { mustBePositive } = 4.5
    kwargs.mesh_smoothing_on (1,1) logical = true;
    kwargs.mesh_smoothing_repetitions (1,1) double { mustBeNonnegative, mustBeInteger } = 1
    kwargs.meshing_threshold (1,1) double { mustBePositive } = 0.25
    kwargs.pml_max_size (1,1) double { mustBePositive } = 2
    kwargs.pml_max_size_unit (1,1) double { mustBeMember ( kwargs.pml_max_size_unit, [1, 2] ) } = 1
    kwargs.pml_outer_radius (1,1) double { mustBePositive } = 1.1
    kwargs.pml_outer_radius_unit (1,1) double { mustBeMember ( kwargs.pml_outer_radius_unit, [1, 2] ) } = 1
    kwargs.reduce_labeling_outliers (1,1) logical = true
    kwargs.refinement_on (1,1) logical = true;
    kwargs.refinement_surface_compartments (1,:) double { mustBeInteger } = [10 -1 1 18 17]
    kwargs.refinement_surface_compartments_2 (1,:) double { mustBeInteger } = -1
    kwargs.refinement_surface_number (1,:) double { mustBeInteger } = 1
    kwargs.refinement_surface_number_2 (1,:) double { mustBeInteger } = 1
    kwargs.refinement_surface_on (1,1) logical = true
    kwargs.refinement_surface_on_2 (1,1) logical = false
    kwargs.refinement_volume_compartments (1,:) double { mustBeInteger } = -1
    kwargs.refinement_volume_compartments_2 (1,:) double { mustBeInteger } = -1
    kwargs.refinement_volume_number (1,:) double { mustBeInteger } = 1
    kwargs.refinement_volume_number_2 (1,:) double { mustBeInteger } = 1
    kwargs.refinement_volume_on (1,1) logical = false
    kwargs.refinement_volume_on_2 (1,1) logical = false
    kwargs.smoothing_steps_ele (1,1) double { mustBePositive } = 0.2
    kwargs.smoothing_steps_surf (1,1) double { mustBePositive } = 0.10
    kwargs.smoothing_steps_vol (1,1) double { mustBePositive } = 0.90
    kwargs.use_fem_mesh_inflation (1,1) logical = true
end

% Start up Zeffiro Interface.

project_struct = zeffiro_interface( 'start_mode', kwargs.start_mode, 'import_to_existing_project', kwargs.input_project_path, 'use_gpu', kwargs.use_gpu ) ;

% Set all parameters needed in mesh construction as an example.

project_struct = utilities.structs.copy_fields ( kwargs, project_struct ) ;

% Create finite element mesh.

project_struct = zef_create_finite_element_mesh ( project_struct ) ;

% Save the mesh to a file.

zef_save ( project_struct, kwargs.output_project_file, kwargs.output_project_dir ) ;

end % function
