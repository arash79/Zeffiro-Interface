function names = zef_session_shell_names(zef)
%ZEF_SESSION_SHELL_NAMES  Fields that survive a project switch.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   names = zef_session_shell_names(zef)
%
%   The shell is the application around the project: machine fields,
%   the default catalog except project payload, and the profile tables
%   the GUI reads (parameter_profile, init_profile). sensors_canonical
%   stays with the session until the file itself carries the flag.
%   file and file_path are the import dialog's last choice, not the
%   project MAT, so they stay until startup clears them.
%
%   Compartment tags, sensor tags, and their <tag>_* arrays are not
%   shell fields. zef_merge_project_data drops them when the new file
%   does not contain them.
%
%   See also zef_merge_project_data, zef_session_defaults, zef_system_field_names.

catalog = fieldnames(zef_session_defaults(struct('font_size', 0)));
shell = setdiff(catalog, project_payload_names(), 'stable');

sys = {};
if nargin >= 1 && isstruct(zef) && isfield(zef, 'program_path') && ~isempty(zef.program_path)
    try
        sys = zef_system_field_names(zef, fieldnames(zef));
    catch
        sys = {};
    end
end

names = unique([shell(:); sys(:); { ...
    'fieldnames'; 'parameter_profile'; 'init_profile'; 'sensors_canonical'; ...
    'file'; 'file_path'}]);

end

function names = project_payload_names()
% Project state in the default catalog. Absent from an incoming file,
% these are removed and later refilled empty by zef_fill_missing_defaults.
% Preferences and lookup tables stay in the shell.

names = { ...
    'sensors'; 'reuna_p'; 'reuna_t'; 'nodes'; 'tetra'; 'tetra_raw'; 'nodes_raw'; ...
    'domain_labels'; 'domain_labels_raw'; 'sigma'; 'sigma_vec'; 'sigma_anisotropy'; ...
    'sigma_prisms'; 'sensors_attached_volume'; 'surface_triangles'; 'L'; ...
    'source_positions'; 'source_directions'; 'brain_ind'; 'source_ind'; ...
    'source_interpolation_ind'; 'measurements'; 'reconstruction'; ...
    'top_reconstruction'; 'noise_data'; 'current_pattern'; 'inv_bg_data'; ...
    'non_source_ind'; 'active_compartment_ind'; 'reuna_distance_vec'; ...
    'reuna_submesh_ind'; 'reuna_mesh_ind'; 'prisms'; 'forward_simulation_table'; ...
    'forward_simulation_selected'; 'zeffiro_variable_data'; 'project_matfile'; ...
    'strip_tool'; 'dynamical_plot_queue_table'; 'dpq_selected'; 'n_sources_mod'; ...
    'lead_field_id'; 'lead_field_id_max'; 'submesh_num'; ...
    'parcellation_plot_type'; 'parcellation_time_series'; 'parcellation_colormap'; ...
    'parcellation_interp_ind'; 'parcellation_name'; 'parcellation_colortable'; ...
    'use_parcellation'; 'parcellation_merge'; 'parcellation_points'; ...
    'parcellation_segment'; 'parcellation_tolerance'; 'parcellation_selected'; ...
    'parcellation_type'; 'parcellation_quantile'; 'parcellation_compartment'; ...
    'inv_rec_source'; 'inv_synth_source'; 'inv_roi_sphere'};

end
