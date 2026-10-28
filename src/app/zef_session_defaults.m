function defaults = zef_session_defaults(zef)
%ZEF_SESSION_DEFAULTS  Default catalog for a Zeffiro session.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Returns the field values zef_init used to write into its temporary
%   zef_data struct. Does not modify zef, does not read a project file,
%   and does not create compartments or sensors.
%
%   zef_fill_missing_defaults copies a value onto zef only when that
%   field is absent. zef_init then clears import paths and applies the
%   startup profile. zef_session_shell_names keeps every catalog field
%   across a project switch except the project-payload names.
%
%   defaults = zef_session_defaults(zef)
%
%   zef.font_size is required. matlab_release is taken from this MATLAB
%   process, not from zef.
%
%   See also zef_fill_missing_defaults, zef_init, zef_session_shell_names.

defaults = struct();
defaults.imaging_method_cell = {'Scalar field', 'Vector field', 'Vector field gradient'};
defaults.update_colorscale = 1;
defaults.dof_decomposition_type = 2;
defaults.update_lights = 1;
defaults.update_colormap = 1;
defaults.update_zoom = 6;
defaults.update_transparency_reconstruction = 0;
defaults.update_transparency_surface = 0;
defaults.update_transparency_sensor = 0;
defaults.update_transparency_cones = 0;
defaults.update_transparency_additional = 0;
defaults.update_brightness = 0;
defaults.update_contrast = 0;
defaults.update_ambience = 0.85;
defaults.update_diffusion = 0.5;
defaults.update_specular = 0.1;
defaults.colorscale_min_slider = 0;
defaults.colorscale_max_slider = 0;
defaults.colormap_size = 256;
defaults.colormap_items = {'Monterosso','Intensity I','Intensity II','Intensity III','Contrast I','Contrast II','Contrast III','Contrast IV','Contrast V','Blue brain I','Blue brain II','Blue brain III','Parcellation','Easter','Greyscale'};
defaults.smoothing_steps_ele = 0.2;
defaults.use_pem = 0;
defaults.default_impedance_value = 5E3;
defaults.cone_alpha = 1;
defaults.streamline_draw = 0;
defaults.streamline_linestyle = '-';
defaults.streamline_linewidth = 1;
defaults.streamline_color = 'blue';
defaults.n_streamline = 100;
defaults.cone_draw = 0;
defaults.cone_lattice_resolution = 10;
defaults.cone_scale = 0.5;
defaults.lead_field_id = 0;
defaults.lead_field_id_max = 0;
defaults.inv_amplitude_db = 20;
defaults.lock_on = 0;
defaults.lock_sensor_names_on = 0;
defaults.lock_transforms_on = 0;
defaults.lock_sensor_sets_on = 0;
defaults.sensors_visual_size = 3.5;
defaults.project_notes = '';
% Project-format stamp for load migrations, not the user-facing product name
% (Zeffiro Interface V2).
defaults.current_version = 6.0;
defaults.font_size = zef.font_size;
defaults.matlab_release = version('-release');
defaults.matlab_release = str2num(defaults.matlab_release(1:4)) + double(defaults.matlab_release(5))/128;
defaults.zeffiro_restart = 0;
defaults.verbose_mode = 1;
defaults.use_waitbar = 1;
defaults.always_show_waitbar = 0;

%%% Here begins initialization variables
defaults.sensor_explosion_parameter_1 = 3;
defaults.sensor_explosion_parameter_2 = 0;
defaults.smooth_field_steps = 3;
defaults.lead_field_filter_quantile = 1.000;
defaults.inv_data_mode = 'filtered_temporal';
defaults.reduce_labeling_outliers = 1;
defaults.adaptive_refinement_number = 1;
defaults.adaptive_refinement_compartments = -1;
defaults.compartment_table_size = 9;
defaults.adaptive_refinement_on = 0;
defaults.adaptive_refinement_thresh_val = 2;
defaults.adaptive_refinement_k_param = 5;
defaults.zeffiro_current_size = cell(0);
defaults.plugin_cell = [];
defaults.active_compartment_ind = [];
defaults.init_profile = [];
defaults.forward_simulation_table = [];
defaults.bypass_inflate = 0;
defaults.imaging_method= 1;
defaults.dynamical_plot_queue_table = cell(0);
defaults.dpq_selected = 1;
defaults.name_tags = cell(0);
defaults.project_tag = '';
defaults.volumetric_distribution_mode = 1;
defaults.normalize_lead_field = 4;
defaults.source_space_creation_iterations = 2;
defaults.exclude_box = 1;
defaults.fix_outer_surface = 1;
defaults.mesh_relabeling = 1;
defaults.pml_outer_radius_unit = 1;
defaults.pml_outer_radius = 1.1;
defaults.pml_max_size_unit = 1;
defaults.pml_max_size = 2;
defaults.initial_mesh_mode = 1;
defaults.sigma_anisotropy = [];
defaults.zeffiro_variable_data = cell(0);
defaults.project_matfile = '';
defaults.noise_data = [];
defaults.top_reconstruction = [];
defaults.colortune_param = 1;
defaults.submesh_num = 0;
defaults.parcellation_plot_type = 1;
defaults.parcellation_time_series = [];
defaults.parcellation_colormap = [];
defaults.parcellation_interp_ind = cell(0);
defaults.parcellation_name = '';
defaults.parcellation_colortable = cell(0);
defaults.use_parcellation = 0;
defaults.parcellation_merge = 1;
defaults.parcellation_points = cell(0);
defaults.parcellation_segment = 'LH';
defaults.parcellation_tolerance = 5;
defaults.parcellation_selected = [];
defaults.parcellation_type = [1];
defaults.parcellation_quantile = [0.98];
defaults.use_gpu_graphic = 0;

defaults.loop_movie = [0];
defaults.loop_movie_count = [5];
defaults.stop_movie = [0];
defaults.inv_init_guess_mode = [1];
defaults.inv_eit_noise = 0;
defaults.inv_bg_data = [];
defaults.inv_roi_perturbation = 0.1;
defaults.current_pattern = [];
defaults.inv_multires_n_decompositions = [20];
defaults.inv_multires_n_levels = [3];
defaults.inv_multires_sparsity = 8;
defaults.h_rec_source = [];
defaults.h_synth_source = [];
defaults.h_roi_sphere = [];
defaults.inv_rec_source = [0 0 0 1 0 0 0 3 1];
defaults.inv_synth_source = [0 0 0 1 0 0 10 0 3 1];
defaults.inv_roi_sphere = [0 0 0 15];
defaults.inv_n_burn_in = 10;
defaults.reconstruction_type = 7;
defaults.h_colorbar   = [];
defaults.location_unit= 1;
defaults.elevation= 0;
defaults.azimuth= 0;
defaults.axes_visible= 0;
% Mesh-tool / Forward defaults: 10000 sources, 3 mm lattice, electrodes
% attached, Normal directions (2), SSOR PCG (preconditioner=2 below).
defaults.n_sources= 10000;
defaults.mesh_resolution= 3;
defaults.attach_electrodes= 1;
defaults.reuna_distance_vec = [];

defaults.source_direction_mode = 2;

defaults.sensors = [];
defaults.reuna_p = cell(0);
defaults.reuna_t = cell(0);
defaults.nodes   = [];
defaults.tetra  = [];
defaults.save_file_path = './data/';
defaults.save_file = 'default_project.mat';
defaults.tetra_raw = [];
defaults.nodes_raw = [];

defaults.cam_va = 6;
defaults.preconditioner = 2;
defaults.solver_tolerance = 1e-6;
defaults.preconditioner_tolerance= 0.001;
defaults.domain_labels_raw=[];
defaults.domain_labels = [];
defaults.sigma=[];
defaults.sigma_vec=[];
defaults.sensors_attached_volume = [];
defaults.surface_triangles = cell(0);
defaults.n_sources_mod     = 0;
defaults.n_sources_old     = 10000;
defaults.location_unit_current = 1;
defaults.L = [];
defaults.source_positions = [];
defaults.source_directions = [];
defaults.brain_ind = [];
defaults.source_ind = [];
defaults.show_contour = 0;
defaults.show_contour_text = 0;
defaults.contour_set_text = '0.1:0.2:0.9';
defaults.contour_n_smoothing = 2;
defaults.contour_line_width = 1;

defaults.strip_tool = struct;
defaults.strip_tool.strip_current_id = 1;
defaults.cp_on       = 0;
defaults.cp_a        = 1;
defaults.cp_b        = 0;
defaults.cp_c        = 0;
defaults.cp_d        = 0;
defaults.meshing_accuracy = 1;
defaults.on_screen        = 0;
defaults.mesh_smoothing_on = 0;
defaults.forward_simulation_selected = [];
defaults.forward_simulation_table = cell(0);
defaults.prisms = [];
defaults.sigma_prisms = [];
defaults.smoothing_strength = 0.40;
defaults.smoothing_steps_surf = 0.10;
defaults.smoothing_steps_vol = 0.90;
defaults.refinement_on = 0;
defaults.refinement_volume_on = 0;
defaults.refinement_volume_number = 1;
defaults.refinement_volume_on_2 = 0;
defaults.refinement_volume_number_2 = 1;
defaults.refinement_surface_number = 1;
defaults.refinement_surface_number_2 = 1;
defaults.refinement_surface_mode = 1;
defaults.refinement_surface_mode_2 = 1;
defaults.refinement_surface_on = 0;
defaults.refinement_surface_on_2 = 0;
defaults.refinement_volume_compartments = -1;
defaults.refinement_volume_compartments_2 = -1;
defaults.refinement_surface_compartments = -1;
defaults.refinement_surface_compartments_2 = -1;
defaults.surface_sources = 0;
defaults.visualization_type = 1;
defaults.source_interpolation_on = 0;
defaults.extensive_relabeling = 0;
defaults.priority_mode = 1;
defaults.measurements = [];
defaults.reconstruction = [];
defaults.inv_hyperprior = [1];
defaults.inv_hyperprior_weight = [0];
defaults.inv_n_map_iterations = [1];
defaults.inv_sampling_frequency = [20000];
defaults.inv_low_cut_frequency = [20];
defaults.inv_high_cut_frequency = [250];
defaults.inv_data_segment = [1];
defaults.source_interpolation_ind = [];
defaults.cp2_on = 0;
defaults.cp2_a = 1;
defaults.cp2_b = 0;
defaults.cp2_c = 0;
defaults.cp2_d = 0;
defaults.cp3_on = 0;
defaults.cp3_a = 1;
defaults.cp3_b = 0;
defaults.cp3_c = 0;
defaults.cp3_d = 0;
defaults.inv_dynamic_range = 1e2;
defaults.inv_scale = 2;
defaults.inv_colormap = 5;
defaults.brain_transparency = 1;
defaults.layer_transparency = 1;
defaults.meshing_threshold = 0.25;
defaults.clear_axes1 = 1;
defaults.normalize_data = 1;
defaults.cp_mode = 1;
defaults.inv_time_1 = 0;
defaults.inv_time_2 = 0.002;
defaults.inv_time_3 = 0.001;
defaults.number_of_frames = 1;
defaults.frame_start = 0;
defaults.frame_stop = 0;
defaults.frame_step = 1;
defaults.orbit_1 = 0;
defaults.orbit_2 = 0;
defaults.non_source_ind = [];
% Numeric 2 = H(div) (core.types.ZefSourceModel.from). Later option
% dialogs may write the enum instead.
defaults.source_model = 2;
defaults.use_depth_electrodes = 0;
defaults.inv_hyperprior_tail_length_db = 10;
defaults.inv_prior_over_measurement_db = 20;
defaults.inv_snr = 30;
defaults.downsample_surfaces = 1;
defaults.max_surface_face_count = 1;
defaults.inflate_n_iterations = 500;
defaults.inflate_strength = 0.8;
defaults.use_inflated_surfaces = 0;
defaults.use_fem_mesh_inflation = 1;
defaults.fem_mesh_inflation_strength = 0.05;
defaults.explode_everything = 1;
defaults.colormap_cell = {'zef_monterosso_colormap','zef_intensity_1_colormap','zef_intensity_2_colormap','zef_intensity_3_colormap','zef_contrast_1_colormap','zef_contrast_2_colormap','zef_contrast_3_colormap','zef_contrast_4_colormap','zef_contrast_5_colormap','zef_blue_brain_1_colormap','zef_blue_brain_2_colormap','zef_blue_brain_3_colormap','zef_parcellation_colormap','zef_easter_colormap','zef_greyscale_colormap'};
defaults.parcellation_compartment = {'g'};
defaults.compartment_activity = {'Bounding box','Inactive','Constrained field','Unconstrained field','Active surface'};
defaults.mesh_smoothing_repetitions = 1;
defaults.mesh_optimization_repetitions = 10;
defaults.mesh_optimization_parameter = 1E-5;
defaults.mesh_labeling_approach = 1;
defaults.current_log_file = '';
defaults.distance_smoothing_exp = 0.01;
defaults.distance_smoothing_on = 1;
defaults.smoothing_steps_dist = 0.9;
defaults.reuna_submesh_ind = cell(0);
defaults.reuna_mesh_ind = [];

end
