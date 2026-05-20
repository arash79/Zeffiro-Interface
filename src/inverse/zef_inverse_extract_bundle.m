function bundle = zef_inverse_extract_bundle(zef, method_id, opts)
% --- Zeffiro documentation header ---
% zef_inverse_extract_bundle — Zef inverse extract bundle.
%
% Purpose:
%   Zef inverse extract bundle.
%   Folder: Inverse orchestration: filtered measurements, lead-field processing, `zef_inverse_run`, bundle extraction, and post-processing into `zef.reconstruction`.
%
% Inputs:
%   zef
%   method_id
%   opts
%
% Outputs:
%   bundle
%
% Zef fields (observed):
%   zef.inverse_initialization_measurements (read)
%   zef.source_direction_mode (read)
%   zef.source_positions (read)
%   zef.use_gpu (read)
%
% Calls (project):
%   inverse.CommonInverseParameters
%   utilities.cluster.inverse_method_registry
%   zef_getFilteredDataClassObj
%   zef_getTimeStepClassObj
%   zef_inverse_extract_bundle
%   zef_processLeadfields
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[bundle] = zef_inverse_extract_bundle(zef, method_id, opts)` with project root and `src` on the path.
% --- End Zeffiro documentation header

arguments
    zef (1,1) struct
    method_id (1,1) string {mustBeNonempty}
    opts.MethodParams (1,1) struct = struct
end

method_info = utilities.cluster.inverse_method_registry(method_id);

[L, n_interp, procFile] = zef_processLeadfields(zef);
source_direction_mode = zef.source_direction_mode;

if source_direction_mode == 1 || source_direction_mode == 2
    s_reorder_ind = reshape((1:n_interp) + (0:n_interp:(2*n_interp))', [], 1);
    L = L(:, s_reorder_ind);
end

source_positions = zef.source_positions(procFile.s_ind_0, :);

common_params = inverse.CommonInverseParameters();
common_params = common_params.withPropertiesFromZef(zef);

f_data = zef_getFilteredDataClassObj(zef, common_params);
F = cell2mat(arrayfun( ...
    @(idx) zef_getTimeStepClassObj(f_data, idx, zef, common_params), ...
    1:common_params.number_of_frames, ...
    'UniformOutput', false ...
));

bundle = struct;
bundle.version = 1;
bundle.method_id = method_id;
bundle.method_info = method_info;
bundle.method_params = opts.MethodParams;
bundle.L = L;
bundle.procFile = procFile;
bundle.source_direction_mode = source_direction_mode;
bundle.source_positions = source_positions;
bundle.F = F;
if isfield(zef, "inverse_initialization_measurements") && ~isempty(zef.inverse_initialization_measurements)
    bundle.F_initialize = zef.inverse_initialization_measurements;
end
bundle.number_of_frames = common_params.number_of_frames;
bundle.use_gpu = isfield(zef, "use_gpu") && logical(zef.use_gpu);
bundle.gpu_count = i_get_field(zef, "gpu_count", 0);
bundle.normalize_data = i_get_field(zef, "normalize_data", 1);
bundle.common_inverse_parameters = struct( ...
    "low_cut_frequency", common_params.low_cut_frequency, ...
    "high_cut_frequency", common_params.high_cut_frequency, ...
    "data_normalization_method", common_params.data_normalization_method, ...
    "number_of_frames", common_params.number_of_frames, ...
    "sampling_frequency", common_params.sampling_frequency, ...
    "time_start", common_params.time_start, ...
    "time_window", common_params.time_window, ...
    "time_step", common_params.time_step, ...
    "signal_to_noise_ratio", common_params.signal_to_noise_ratio, ...
    "normalize_reconstruction", common_params.normalize_reconstruction ...
);

if method_info.execution_kind == "legacy"
    bundle.legacy_zef = zef;
end

end

function val = i_get_field(s, field_name, default_val)
if isfield(s, field_name)
    val = s.(field_name);
else
    val = default_val;
end
end
