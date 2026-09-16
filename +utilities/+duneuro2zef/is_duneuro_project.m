function tf = is_duneuro_project(source)
%IS_DUNEURO_PROJECT  True if source is a DUNEuro MATLAB project, not a native Zeffiro MAT.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Native Zeffiro projects win when they carry compartment_tags together
%   with a volume mesh or lead field. DUNEuro markers are the MATLAB-binding
%   / FieldTrip names eegL, eegT, megL, megT, electrodePositions, a
%   headmodel type/method containing "duneuro", or a folder of DUNEuro
%   export files. Detection uses WHOS / folder listing and does not load
%   the transfer matrix.
%
%   tf = is_duneuro_project(path)
%   tf = is_duneuro_project(struct)
%   tf = is_duneuro_project(field_name_cell)
%
%   See also load_raw, convert, import_duneuro_project.

    tf = false;
    if nargin < 1 || isempty(source)
        return
    end

    if isstruct(source)
        tf = local_from_names(fieldnames(source), source);
        return
    end

    if iscell(source) || isstring(source)
        names = cellstr(source);
        if size(names, 1) > 1 || numel(names) > 1
            tf = local_from_names(names(:), struct());
            return
        end
        source = names{1};
    end

    if ischar(source) || (isstring(source) && isscalar(source))
        path = char(source);
        if isfolder(path)
            tf = local_is_duneuro_folder(path);
            return
        end
        if isfile(path)
            tf = local_from_matfile(path);
            return
        end
    end
end

function tf = local_from_matfile(path)
    w = whos('-file', path);
    names = {w.name}';
    peeked = struct();
    if isequal(numel(names), 1) && strcmp(w(1).class, 'struct')
        inner = local_peek_struct_fields(path, names{1});
        if ~isempty(inner)
            names = inner(:);
        elseif w(1).bytes <= 1e8
            raw = load(path);
            payload = raw.(w(1).name);
            if isstruct(payload) && isscalar(payload)
                peeked = payload;
                names = fieldnames(payload);
            end
        end
    end
    tf = local_from_names(names, peeked);
end

function inner = local_peek_struct_fields(path, varname)
    inner = {};
    try
        info = h5info(path, ['/' varname]);
        if isfield(info, 'Datasets') && ~isempty(info.Datasets)
            inner = [inner, {info.Datasets.Name}];
        end
        if isfield(info, 'Groups') && ~isempty(info.Groups)
            gnames = {info.Groups.Name};
            for i = 1:numel(gnames)
                parts = strsplit(gnames{i}, '/');
                inner{end+1} = parts{end}; %#ok<AGROW>
            end
        end
    catch
        inner = {};
    end
end

function tf = local_from_names(names, peeked)
    names = cellstr(names);
    names = names(:);
    if local_is_zeffiro_names(names)
        tf = false;
        return
    end
    if local_has_duneuro_marker(names)
        tf = true;
        return
    end
    tf = false;
    if isstruct(peeked) && ~isempty(fieldnames(peeked))
        tf = local_headmodel_is_duneuro(peeked);
    end
end

function tf = local_is_zeffiro_names(names)
    has_tags = any(strcmp(names, 'compartment_tags'));
    has_mesh = any(strcmp(names, 'tetra')) || any(strcmp(names, 'nodes'));
    has_zef_l = any(strcmp(names, 'L')) && ~any(strcmp(names, 'eegL')) ...
        && ~any(strcmp(names, 'megL'));
    has_version = any(strcmp(names, 'current_version')) ...
        || any(strcmp(names, 'zeffiro_variable_data'));
    tf = has_tags && (has_mesh || has_zef_l || has_version);
end

function tf = local_has_duneuro_marker(names)
    markers = {'eegL', 'eegT', 'megL', 'megT', 'electrodePositions', ...
        'eeg_transfer', 'meg_transfer', 'LF_EEG', 'LF_MEG'};
    tf = any(ismember(markers, names));
end

function tf = local_headmodel_is_duneuro(s)
    tf = false;
    keys = {'type', 'method'};
    for i = 1:numel(keys)
        if isfield(s, keys{i}) && local_text_has_duneuro(s.(keys{i}))
            tf = true;
            return
        end
    end
    if isfield(s, 'headmodel') && isstruct(s.headmodel)
        tf = local_headmodel_is_duneuro(s.headmodel);
    end
    if isfield(s, 'vol') && isstruct(s.vol)
        tf = tf || local_headmodel_is_duneuro(s.vol);
    end
end

function tf = local_text_has_duneuro(val)
    tf = false;
    try
        tf = contains(lower(char(string(val))), 'duneuro');
    catch
        tf = false;
    end
end

function tf = local_is_duneuro_folder(folder)
    listing = dir(folder);
    names = {listing(~[listing.isdir]).name};
    has_mesh = any(strcmpi(names, 'mesh.mat'));
    has_lf = any(strcmpi(names, 'LF_EEG.mat')) || any(strcmpi(names, 'LF_MEG.mat')) ...
        || any(strcmpi(names, 'eegL.mat')) || any(contains(lower(names), 'leadfield'));
    has_sensors = any(strcmpi(names, 'sensors.mat')) ...
        || any(strcmpi(names, 'electrodePositions.mat'));
    tf = has_mesh || (has_lf && has_sensors) || has_lf;
end
