function zef = createSyntheticMeshZef()
%CREATESYNTHETICMESHZEF  Closed 20 mm cube compartment for mesh pipeline tests.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = createSyntheticMeshZef()
%
%   Not a test. One active compartment `c1` with an outward-wound cube
%   surface, identity affine, refinement off, empty sensors, and the
%   zef_init defaults use_gpu=0 / surface_sources=0 / n_sources=10000 /
%   dof_decomposition_type=2. Intended for zef_process_meshes /
%   zef_create_fem_mesh and cube FEM assembly tests, not inverse dispatch.

zef = struct();
zef.compartment_tags = {'c1'};
zef.compartment_activity = {'Bounding box', 'Inactive', ...
    'Constrained field', 'Unconstrained field', 'Active surface'};
zef.c1_on = 1;
zef.c1_name = 'cube';
zef.c1_sigma = 0.33;
zef.c1_priority = 1;
zef.c1_sources = 2;
zef.c1_scaling = 1;
zef.c1_x_correction = 0;
zef.c1_y_correction = 0;
zef.c1_z_correction = 0;
zef.c1_xy_rotation = 0;
zef.c1_yz_rotation = 0;
zef.c1_zx_rotation = 0;
zef.c1_affine_transform = {eye(4)};
zef.c1_points_inf = [];
zef.c1_submesh_ind = 12;
zef.c1_points = [ ...
    0 0 0; 20 0 0; 20 20 0; 0 20 0; ...
    0 0 20; 20 0 20; 20 20 20; 0 20 20];
zef.c1_triangles = [ ...
    1 4 3; 1 3 2; ...
    5 6 7; 5 7 8; ...
    1 2 6; 1 6 5; ...
    4 8 7; 4 7 3; ...
    1 5 8; 1 8 4; ...
    2 3 7; 2 7 6];

zef.current_sensors = 's';
zef.s_points = [];
zef.s_scaling = 1;
zef.s_x_correction = 0;
zef.s_y_correction = 0;
zef.s_z_correction = 0;
zef.s_xy_rotation = 0;
zef.s_yz_rotation = 0;
zef.s_zx_rotation = 0;
zef.imaging_method = 1;
zef.create_patch_sensor = [];
zef.use_pem = 0;

zef.mesh_resolution = 10;
zef.initial_mesh_mode = 1;
zef.mesh_labeling_approach = 1;
zef.priority_mode = 1;
zef.mesh_relabeling = 0;
zef.distance_smoothing_on = 0;
zef.refinement_on = 0;
zef.refinement_surface_on = 0;
zef.refinement_surface_number = 1;
zef.refinement_surface_compartments = -1;
zef.refinement_volume_on = 0;
zef.refinement_volume_number = 1;
zef.refinement_volume_compartments = -1;
zef.adaptive_refinement_on = 0;
zef.downsample_surfaces = 0;
zef.meshing_threshold = 0.25;
zef.meshing_accuracy = 1;
zef.use_gpu = 0;
zef.gpu_count = 0;
zef.parallel_processes = 1;
zef.parallel_vectors = 1;
zef.processes_per_core = 1;
zef.surface_sources = 0;
zef.n_sources = 10000;
zef.dof_decomposition_type = 2;
end
