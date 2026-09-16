function raw = load_raw(source)
%LOAD_RAW  Load a DUNEuro MATLAB file or export folder without pulling unused transfer matrices.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   MAT files: loads every variable except eegT / megT / eeg_transfer /
%   meg_transfer. Those matrices are DUNEuro FEM internals used to build a
%   lead field; Zeffiro inverse/visualization consume zef.L, not T. Their
%   presence is recorded on raw.duneuro_omitted_fields.
%
%   Folders: loads recognized export files (mesh, sensors, LF_EEG / LF_MEG,
%   source grids, optional measurements) into one struct.
%
%   raw = load_raw(path_or_struct)
%
%   See also is_duneuro_project, convert.

    if nargin < 1 || isempty(source)
        error('duneuro2zef:EmptyProject', 'A DUNEuro file, folder, or struct is required.');
    end

    if isstruct(source)
        raw = source;
        raw = local_mark_omitted_transfer(raw);
        return
    end

    path = char(string(source));
    if isfolder(path)
        raw = local_load_folder(path);
        return
    end
    if ~isfile(path)
        error('duneuro2zef:EmptyProject', 'DUNEuro source not found: %s', path);
    end
    raw = local_load_mat(path);
end

function raw = local_load_mat(path)
    w = whos('-file', path);
    names = {w.name};
    skip = {'eegT', 'megT', 'eeg_transfer', 'meg_transfer', 'transfer'};
    load_names = setdiff(names, skip, 'stable');
    omitted = intersect(names, skip);
    if isempty(load_names)
        raw = struct();
    elseif isequal(numel(load_names), 1) && strcmp(w(strcmp(names, load_names{1})).class, 'struct')
        loaded = load(path, load_names{1});
        payload = loaded.(load_names{1});
        if isstruct(payload) && isscalar(payload)
            raw = payload;
        else
            raw = loaded;
        end
    else
        raw = load(path, load_names{:});
    end
    raw = local_unwrap_single_field(raw);
    raw.duneuro_source_path = path;
    raw.duneuro_omitted_fields = omitted;
end

function raw = local_unwrap_single_field(raw)
    names = fieldnames(raw);
    names = setdiff(names, {'duneuro_source_path', 'duneuro_omitted_fields'}, 'stable');
    if isequal(numel(names), 1) && isstruct(raw.(names{1})) && isscalar(raw.(names{1}))
        inner = raw.(names{1});
        inner.duneuro_source_path = local_get_field(raw, 'duneuro_source_path', '');
        inner.duneuro_omitted_fields = local_get_field(raw, 'duneuro_omitted_fields', {});
        raw = inner;
    end
end

function raw = local_mark_omitted_transfer(raw)
    skip = {'eegT', 'megT', 'eeg_transfer', 'meg_transfer', 'transfer'};
    omitted = skip(isfield(raw, skip));
    for i = 1:numel(omitted)
        raw = rmfield(raw, omitted{i});
    end
    raw.duneuro_omitted_fields = omitted;
end

function raw = local_load_folder(folder)
    raw = struct();
    raw.duneuro_source_path = folder;
    raw.duneuro_omitted_fields = {};

    mesh_path = utilities.duneuro2zef.find_files('mesh.mat', folder, 'first');
    if ~isempty(mesh_path)
        mesh_data = local_first_struct_or_self(load(mesh_path));
        raw.mesh = mesh_data;
    end

    sensor_path = utilities.duneuro2zef.find_files('sensors.mat', folder, 'first');
    if isempty(sensor_path)
        sensor_path = utilities.duneuro2zef.find_files('electrodePositions.mat', folder, 'first');
    end
    if ~isempty(sensor_path)
        raw.sensors = local_first_struct_or_self(load(sensor_path));
    end

    eeg_path = local_first_existing(folder, {'LF_EEG.mat', 'eegL.mat', 'EEG_leadfield.mat'});
    if ~isempty(eeg_path)
        raw.eegL = local_numeric_from_mat(load(eeg_path), {'eegL', 'LF_EEG', 'L', 'lf', 'leadfield'});
    end

    meg_path = local_first_existing(folder, {'LF_MEG.mat', 'megL.mat', 'MEG_leadfield.mat'});
    if ~isempty(meg_path)
        raw.megL = local_numeric_from_mat(load(meg_path), {'megL', 'LF_MEG', 'L', 'lf', 'leadfield'});
    end

    src_path = utilities.duneuro2zef.find_files('sp_vol_rgv_N*.mat', folder, 'smallest');
    if isempty(src_path)
        src_path = utilities.duneuro2zef.find_files('source_space.mat', folder, 'first');
    end
    if ~isempty(src_path)
        raw.source_positions = local_numeric_from_mat(load(src_path), ...
            {'source_grid', 'source_positions', 'positions', 'dipoles'});
    end

    meas_eeg = local_first_existing(folder, {'spikeAvgEEG.mat', 'EEG_measurements.mat', 'eeg_data.mat'});
    if ~isempty(meas_eeg)
        raw.measurements = local_measurements_from_mat(load(meas_eeg));
    end
end

function path = local_first_existing(folder, names)
    path = '';
    for i = 1:numel(names)
        candidate = fullfile(folder, names{i});
        if isfile(candidate)
            path = candidate;
            return
        end
    end
end

function data = local_first_struct_or_self(loaded)
    names = fieldnames(loaded);
    if isequal(numel(names), 1)
        data = loaded.(names{1});
    else
        data = loaded;
    end
end

function val = local_numeric_from_mat(loaded, candidates)
    val = [];
    for i = 1:numel(candidates)
        if isfield(loaded, candidates{i}) && isnumeric(loaded.(candidates{i}))
            val = loaded.(candidates{i});
            return
        end
    end
    names = fieldnames(loaded);
    for i = 1:numel(names)
        data = loaded.(names{i});
        if isnumeric(data) && ~isempty(data)
            val = data;
            return
        end
    end
end

function val = local_measurements_from_mat(loaded)
    val = [];
    data = local_first_struct_or_self(loaded);
    if isnumeric(data)
        val = data;
        return
    end
    if isstruct(data)
        for name = {'avg', 'data', 'measurements', 'trial'}
            if isfield(data, name{1}) && isnumeric(data.(name{1}))
                val = data.(name{1});
                return
            end
        end
    end
end

function val = local_get_field(s, name, default_val)
    if isfield(s, name)
        val = s.(name);
    else
        val = default_val;
    end
end
