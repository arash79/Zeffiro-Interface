function [payload, report] = convert(source)
%CONVERT  DUNEuro MATLAB/FieldTrip project → native Zeffiro scientific fields.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Pipeline: identify → validate → convert coordinates/indexing/units →
%   mesh/compartments → sensors → sources → lead field → metadata →
%   consistency checks. Does not recompute a lead field or remesh a valid
%   tetrahedral grid. Hexahedra are split with zef_hexa_to_tetra because
%   Zeffiro's runtime mesh is tetrahedral.
%
%   Lead field: DUNEuro / FieldTrip store EEG L as n_sensors × 3*n_sources
%   with columns [x1 y1 z1 x2 y2 z2 ...] (leadfield_duneuro.m). 3-D dumps
%   such as (n_sensors, n_sources, 3) or (3, n_sources, n_sensors) are
%   permuted onto that layout using the electrode count as the sensor axis.
%   When n_sources is also 3, (n_sensors, 3, 3) is taken as orientation-last
%   (the usual MATLAB dump of per-source xyz). This matches raw zef.L
%   consumed by zef_processLeadfields (interleaved xyz) and, after that
%   function's block reorder plus zef_inverse_extract_bundle,
%   inverse.ELORETAInverter's reshape(L, n_sensors, 3, n_sources).
%
%   Electrodes: duneuro-matlab / FieldTrip pass 3×n_electrodes into
%   set_electrodes (columns are sensors). Zeffiro stores N×3 millimetres.
%
%   Units: DUNEuro does not convert mesh units. A unit field is honoured
%   when present. Otherwise a head-sized bounding box maps millimetres vs
%   metres (diagonal in [50, 500] → mm; [0.05, 0.5] → m, ×1000). Lead-field
%   values stay in SI V/(A·m); they are not scaled with display units.
%
%   Indexing: DUNE/DUNEuro elements may be 0-based; they are shifted to
%   MATLAB 1-based when min(elements)==0. Tissue IDs are remapped onto
%   consecutive Zeffiro compartment indices 1:n (original IDs kept in
%   duneuro_import.original_tissue_ids and default compartment names).
%
%   Hexahedra: split with zef_hexa_to_tetra in DUNE/ndgrid corner order.
%   If that split is degenerate, VTK order (bottom 1 2 4 3) is retried.
%
%   [payload, report] = convert(path_or_struct)
%
%   See also import_duneuro_project, load_raw, is_duneuro_project.

    if nargin < 1 || isempty(source)
        error('duneuro2zef:EmptyProject', 'A DUNEuro file, folder, or struct is required.');
    end

    raw = utilities.duneuro2zef.load_raw(source);
    report = local_empty_report();
    if isfield(raw, 'duneuro_source_path')
        report.source_path = raw.duneuro_source_path;
    elseif ischar(source) || isstring(source)
        report.source_path = char(string(source));
    else
        report.source_path = '';
    end
    omitted = {};
    if isfield(raw, 'duneuro_omitted_fields')
        omitted = raw.duneuro_omitted_fields;
    end
    for i = 1:numel(omitted)
        report.omitted{end+1} = sprintf( ...
            '%s (DUNEuro transfer matrix; FEM internal, not a Zeffiro runtime field)', ...
            omitted{i});
    end

    payload = local_empty_payload();
    payload.duneuro_import = struct( ...
        'source_path', report.source_path, ...
        'format', 'duneuro_matlab', ...
        'length_unit', 'mm', ...
        'lead_field_layout', '', ...
        'imported', {{}}, ...
        'omitted', {report.omitted}, ...
        'warnings', {{}});

    [electrodes, electrode_aux] = local_find_electrodes(raw);
    n_electrodes = size(electrodes, 1);
    if ~isempty(electrode_aux)
        payload.duneuro_import.electrode_aux = electrode_aux;
        report.omitted{end+1} = ['electrode extra columns (CEM radii/impedance; ' ...
            'Zeffiro sensors are PEM N×3). Stored on duneuro_import.electrode_aux'];
        report.warnings{end+1} = ['Electrode array had extra columns beyond xyz. ' ...
            'Positions use the first three columns (PEM).'];
    end

    eeg_lf = local_find_leadfield(raw, 'eeg');
    meg_lf = local_find_leadfield(raw, 'meg');
    modality = 'EEG';
    raw_lf = eeg_lf;
    if isempty(raw_lf) && ~isempty(meg_lf)
        raw_lf = meg_lf;
        modality = 'MEG';
    elseif ~isempty(eeg_lf) && ~isempty(meg_lf)
        report.warnings{end+1} = ['Both EEG and MEG lead fields are present. ' ...
            'zef.L receives the EEG matrix; the MEG matrix is not stacked onto it.'];
        report.omitted{end+1} = 'megL (second modality; Zeffiro holds one zef.L)';
    end

    if ~isempty(raw_lf)
        [payload.L, lf_info] = local_convert_leadfield(raw_lf, n_electrodes, modality);
        n_electrodes = lf_info.n_sensors;
        payload.n_sources = lf_info.n_sources;
        payload.lead_field_type = lf_info.lead_field_type;
        payload.imaging_method = lf_info.imaging_method;
        payload.duneuro_import.lead_field_layout = lf_info.layout;
        report.imported{end+1} = 'L';
    end

    if ~isempty(electrodes)
        [electrodes, report] = local_apply_length_unit(electrodes, raw, report);
        payload.sensors = electrodes;
        payload.s_points = electrodes;
        payload.s_on = 1;
        payload.s_visible = 1;
        payload.s_imaging_method_name = modality;
        payload.s_name = [modality ' electrodes'];
        payload.s_name_list = local_find_electrode_labels(raw, size(electrodes, 1));
        payload.sensor_tags = {'s'};
        payload.current_sensors = 's';
        payload.imaging_method = local_imaging_method_for(modality);
        report.imported{end+1} = 'sensors';
        if ~isempty(payload.L) && size(payload.L, 1) ~= size(electrodes, 1)
            error('duneuro2zef:SensorLeadFieldMismatch', ...
                'Lead field has %d sensor rows but %d electrode positions.', ...
                size(payload.L, 1), size(electrodes, 1));
        end
    elseif ~isempty(payload.L)
        report.warnings{end+1} = 'Lead field imported without electrode coordinates.';
    end

    [nodes, tetra, domain_labels, hex_converted, original_ids] = local_convert_mesh(raw);
    if hex_converted
        report.warnings{end+1} = ['Hexahedral DUNEuro elements were split into tetrahedra ' ...
            'with zef_hexa_to_tetra (Zeffiro volume meshes are tetrahedral).'];
    end
    if ~isempty(nodes)
        [nodes, report] = local_apply_length_unit(nodes, raw, report);
        payload.nodes = nodes;
        payload.tetra = tetra;
        payload.domain_labels = domain_labels;
        payload.duneuro_import.original_tissue_ids = original_ids;
        report.imported{end+1} = 'mesh';
        [payload, report] = local_fill_compartments(payload, raw, original_ids, report);
    else
        payload.nodes = [];
        payload.tetra = [];
        payload.domain_labels = [];
        payload.sigma = [];
        payload.brain_ind = [];
        payload.active_compartment_ind = [];
    end

    [source_positions, source_directions, source_model] = local_convert_sources(raw);
    if ~isempty(source_positions)
        [source_positions, report] = local_apply_length_unit(source_positions, raw, report);
        payload.source_positions = source_positions;
        report.imported{end+1} = 'source_positions';
        if ~isempty(payload.L) && size(payload.L, 2) == 3 * size(source_positions, 1)
            payload.n_sources = size(source_positions, 1);
        elseif ~isempty(payload.L) && size(payload.L, 2) ~= 3 * size(source_positions, 1) ...
                && size(payload.L, 2) ~= size(source_positions, 1)
            error('duneuro2zef:InvalidLeadField', ...
                'Lead field has %d columns but %d source positions (expected 3N or N).', ...
                size(payload.L, 2), size(source_positions, 1));
        end
    end
    if ~isempty(source_directions)
        payload.source_directions = source_directions;
        report.imported{end+1} = 'source_directions';
    end
    if ~isempty(source_model)
        payload.source_model = source_model;
        report.imported{end+1} = 'source_model';
    end

    measurements = local_find_measurements(raw);
    if ~isempty(measurements)
        payload.measurements = local_orient_measurements(measurements, n_electrodes);
        report.imported{end+1} = 'measurements';
    end

    tensors = local_find_tensors(raw);
    conductivity = local_find_conductivity(raw);
    if ~isempty(payload.tetra)
        [payload.sigma, report] = local_pack_sigma(payload, conductivity, tensors, hex_converted, report);
        if any(payload.sigma(:, 1) > 0)
            report.imported{end+1} = 'conductivity';
        end
        if size(payload.sigma, 2) >= 8
            report.imported{end+1} = 'anisotropy';
        end
    elseif ~isempty(tensors) || ~isempty(conductivity)
        report.omitted{end+1} = 'conductivity/tensors (no mesh to attach them to)';
    end

    if ~isempty(payload.L)
        n_src = local_source_count(payload);
        payload.source_interpolation_ind = {(1:n_src)', [], []};
        if mod(size(payload.L, 2), 3) == 0
            payload.source_direction_mode = 1;
        else
            payload.source_direction_mode = 3;
            report.warnings{end+1} = ['Lead-field columns are not Cartesian xyz triplets. ' ...
                'source_direction_mode=3 (one column per source).'];
        end
        if isempty(payload.source_positions)
            report.warnings{end+1} = ['Source coordinates are not in this DUNEuro file. ' ...
                'zef.L is imported; spatial inverse plotting needs source_positions.'];
        end
    end

    if ~isempty(payload.nodes) && ~isempty(payload.source_positions)
        payload = local_mark_source_compartments(payload);
    end

    local_require_something(payload);
    local_consistency_checks(payload);

    if isfield(report, 'length_unit') && ~isempty(report.length_unit)
        payload.duneuro_import.length_unit = report.length_unit;
    end
    payload.duneuro_import.imported = report.imported;
    payload.duneuro_import.omitted = report.omitted;
    payload.duneuro_import.warnings = report.warnings;
    report.payload_fields = fieldnames(payload);
end

function report = local_empty_report()
    report = struct();
    report.source_path = '';
    report.imported = {};
    report.omitted = {};
    report.warnings = {};
    report.payload_fields = {};
end

function payload = local_empty_payload()
    payload = struct();
    payload.L = [];
    payload.nodes = [];
    payload.tetra = [];
    payload.domain_labels = [];
    payload.sigma = [];
    payload.sensors = [];
    payload.s_points = [];
    payload.source_positions = [];
    payload.source_directions = [];
    payload.source_ind = [];
    payload.brain_ind = [];
    payload.active_compartment_ind = [];
    payload.sensors_attached_volume = [];
    payload.measurements = [];
    payload.reconstruction = [];
    payload.n_sources = [];
    payload.location_unit = 1;
    payload.lead_field_id = 1;
    payload.source_direction_mode = 1;
    payload.lead_field_type = 1;
    payload.imaging_method = 1;
    payload.compartment_tags = {};
    payload.sensor_tags = {};
    payload.current_version = 6.0;
end

function [electrodes, extra] = local_find_electrodes(raw)
    electrodes = [];
    extra = [];
    val = local_find_named(raw, {'electrodePositions', 'electrode_positions', ...
        'elecpos', 'electrodes'}, 2);
    if isempty(val) && isfield(raw, 'sensors')
        sensors = raw.sensors;
        if isstruct(sensors)
            if isfield(sensors, 'elec') && isstruct(sensors.elec) && isfield(sensors.elec, 'chanpos')
                val = sensors.elec.chanpos;
            elseif isfield(sensors, 'chanpos')
                val = sensors.chanpos;
            elseif isfield(sensors, 'elecpos')
                val = sensors.elecpos;
            end
        elseif isnumeric(sensors)
            val = sensors;
        end
    end
    if isempty(val) && isfield(raw, 'elec') && isstruct(raw.elec) && isfield(raw.elec, 'chanpos')
        val = raw.elec.chanpos;
    end
    if isempty(val)
        return
    end
    if isnumeric(val) && ismatrix(val)
        if size(val, 2) > 3 && size(val, 1) ~= 3
            extra = val(:, 4:end);
            val = val(:, 1:3);
        elseif size(val, 1) > 3 && size(val, 2) ~= 3
            extra = val(4:end, :).';
            val = val(1:3, :).';
        end
    end
    electrodes = local_as_n_by_k(val, 3, 'electrode positions');
    if ~all(isfinite(electrodes(:)))
        error('duneuro2zef:InvalidSensors', 'Electrode coordinates contain non-finite values.');
    end
end

function labels = local_find_electrode_labels(raw, n)
    labels = arrayfun(@(k) sprintf('E%d', k), (1:n)', 'UniformOutput', false);
    val = local_find_named(raw, {'label', 'labels', 'electrode_labels', 'chanlabel'}, 2);
    if isempty(val) && isfield(raw, 'sensors') && isstruct(raw.sensors)
        if isfield(raw.sensors, 'elec') && isfield(raw.sensors.elec, 'label')
            val = raw.sensors.elec.label;
        elseif isfield(raw.sensors, 'label')
            val = raw.sensors.label;
        end
    end
    if isempty(val)
        return
    end
    if ischar(val)
        val = cellstr(val);
    end
    if isstring(val)
        val = cellstr(val);
    end
    if iscell(val) && numel(val) == n
        labels = val(:);
    end
end

function lf = local_find_leadfield(raw, modality)
    lf = [];
    if strcmp(modality, 'eeg')
        names = {'eegL', 'LF_EEG', 'eeg_lf', 'eeg_leadfield'};
    else
        names = {'megL', 'LF_MEG', 'meg_lf', 'meg_leadfield'};
    end
    lf = local_find_named(raw, names, 2);
    if isempty(lf) && isfield(raw, 'lf') && strcmp(modality, 'eeg')
        lf = raw.lf;
    end
end

function [L, info] = local_convert_leadfield(raw_lf, n_electrodes, modality)
    if ~isnumeric(raw_lf) || isempty(raw_lf)
        error('duneuro2zef:InvalidLeadField', 'Lead field must be a nonempty numeric array.');
    end
    if ~isreal(raw_lf) || ~all(isfinite(raw_lf(:)))
        error('duneuro2zef:InvalidLeadField', 'Lead field must be real and finite.');
    end

    sz = size(raw_lf);
    if numel(sz) > 3
        error('duneuro2zef:InvalidLeadField', ...
            'Lead field has %d dimensions; expected 2-D or 3-D.', numel(sz));
    end

    if numel(sz) == 3 && sz(3) > 1
        L = local_lf_from_3d(raw_lf, n_electrodes);
    else
        L = local_lf_from_2d(raw_lf, n_electrodes);
    end

    info = struct();
    info.n_sensors = size(L, 1);
    info.layout = 'sensors x 3*sources, interleaved xyz per source';
    info.lead_field_type = 1;
    info.imaging_method = 1;
    if strcmp(modality, 'MEG')
        info.lead_field_type = 2;
        info.imaging_method = 2;
    end

    if mod(size(L, 2), 3) == 0
        info.n_sources = size(L, 2) / 3;
    elseif strcmp(modality, 'MEG')
        info.n_sources = size(L, 2);
        info.layout = 'sensors x sources (oriented MEG columns)';
    else
        error('duneuro2zef:InvalidLeadField', ...
            ['EEG lead-field columns (%d) are not a multiple of 3. ' ...
            'DUNEuro Cartesian dipoles are stored as xyz triplets per source.'], size(L, 2));
    end
end

function L = local_lf_from_2d(lf, n_electrodes)
    a = size(lf, 1);
    b = size(lf, 2);
    if ~isempty(n_electrodes) && n_electrodes > 0
        if a == n_electrodes
            L = lf;
            return
        end
        if b == n_electrodes && a ~= n_electrodes
            % Documented DUNEuro/FieldTrip layout is sensors × 3N. This array
            % has sensors on the second dimension, so it is the transpose.
            L = lf.';
            return
        end
        error('duneuro2zef:SensorLeadFieldMismatch', ...
            '2-D lead field size %s does not match %d electrodes on either dimension.', ...
            mat2str(size(lf)), n_electrodes);
    end
    % No electrode count: FieldTrip/DUNEuro 2-D L is sensors (rows) × 3N.
    L = lf;
end

function L = local_lf_from_3d(lf, n_electrodes)
    sz = size(lf);
    elec_dim = local_unique_dim(sz, n_electrodes, 1);
    ori_dim = local_orientation_dim(sz, elec_dim);
    src_dim = setdiff(1:3, [elec_dim, ori_dim]);
    if numel(src_dim) ~= 1
        error('duneuro2zef:InvalidLeadField', ...
            'Cannot separate source and orientation axes in lead-field size %s.', mat2str(sz));
    end
    lf3 = permute(lf, [elec_dim, ori_dim, src_dim]);
    L = reshape(lf3, size(lf3, 1), []);
end

function dim = local_unique_dim(sz, value, fallback)
    dim = fallback;
    if isempty(value) || value <= 0
        if sz(1) ~= 3
            dim = 1;
        elseif sz(end) ~= 3
            dim = numel(sz);
        end
        return
    end
    hits = find(sz == value);
    if isempty(hits)
        error('duneuro2zef:SensorLeadFieldMismatch', ...
            '3-D lead field size %s does not contain electrode count %d.', mat2str(sz), value);
    end
    if numel(hits) == 1
        dim = hits;
        return
    end
    if sz(1) == value
        dim = 1;
    else
        error('duneuro2zef:InvalidLeadField', ...
            'Electrode count %d matches more than one lead-field dimension %s.', value, mat2str(sz));
    end
end

function ori_dim = local_orientation_dim(sz, elec_dim)
    remaining = setdiff(1:3, elec_dim);
    ori_hits = remaining(sz(remaining) == 3);
    if numel(ori_hits) == 1
        ori_dim = ori_hits;
        return
    end
    if isempty(ori_hits)
        error('duneuro2zef:InvalidLeadField', ...
            '3-D lead field has no orientation axis of length 3 (size %s).', mat2str(sz));
    end
    % n_sources == 3 as well as n_orientations. Prefer orientation last
    % (n_sensors, n_sources, 3); else orientation first (3, n_sources, n_sensors).
    if ismember(3, ori_hits)
        ori_dim = 3;
        return
    end
    ori_dim = ori_hits(1);
end

function [nodes, tetra, domain_labels, hex_converted, original_ids] = local_convert_mesh(raw)
    nodes = [];
    tetra = [];
    domain_labels = [];
    hex_converted = false;
    original_ids = [];

    mesh = [];
    if isfield(raw, 'mesh') && isstruct(raw.mesh)
        mesh = raw.mesh;
    elseif isfield(raw, 'volume_conductor') && isstruct(raw.volume_conductor)
        if isfield(raw.volume_conductor, 'grid')
            mesh = raw.volume_conductor.grid;
        else
            mesh = raw.volume_conductor;
        end
    end

    node_src = [];
    elem_src = [];
    label_src = [];
    if isstruct(mesh)
        node_src = local_first_existing_field(mesh, {'nodes', 'pos', 'pnt', 'vertices'});
        elem_src = local_first_existing_field(mesh, {'elements', 'tet', 'tetra', 'hexa', 'hex', 'elm'});
        label_src = local_first_existing_field(mesh, {'labels', 'label', 'tissue', 'domain', 'tag'});
    end
    if isempty(node_src)
        node_src = local_find_named(raw, {'nodes', 'pos'}, 1);
    end
    if isempty(elem_src)
        elem_src = local_find_named(raw, {'elements', 'tetra', 'tet', 'hexa'}, 1);
    end
    if isempty(label_src)
        label_src = local_find_named(raw, {'labels', 'label', 'tissue', 'domain', 'tag'}, 1);
    end
    if ~isempty(label_src) && ~isnumeric(label_src)
        label_src = [];
    end
    if isempty(node_src) || isempty(elem_src)
        return
    end

    nodes = local_as_n_by_k(node_src, 3, 'mesh nodes');
    if ~all(isfinite(nodes(:)))
        error('duneuro2zef:InvalidMesh', 'Mesh nodes contain non-finite coordinates.');
    end

    n_nodes = size(nodes, 1);
    elem = double(elem_src);
    if size(elem, 1) ~= 4 && size(elem, 1) ~= 8 && size(elem, 2) ~= 4 && size(elem, 2) ~= 8
        error('duneuro2zef:InvalidMesh', ...
            'Mesh elements must be tetrahedra (4 nodes) or hexahedra (8 nodes), got size %s.', ...
            mat2str(size(elem)));
    end
    if size(elem, 1) == 4 || size(elem, 1) == 8
        elem = elem.';
    end

    if min(elem(:)) == 0
        elem = elem + 1;
    end
    if min(elem(:)) < 1 || max(elem(:)) > n_nodes
        error('duneuro2zef:InvalidMesh', ...
            'Element indices [%g, %g] fall outside 1:%d nodes.', ...
            min(elem(:)), max(elem(:)), n_nodes);
    end

    if size(elem, 2) == 8
        labels_hex = local_labels_for_elements(label_src, size(elem, 1));
        [tetra, domain_labels] = local_hex_to_tet(nodes, elem, labels_hex);
        hex_converted = true;
    else
        tetra = elem;
        domain_labels = local_labels_for_elements(label_src, size(elem, 1));
    end
    domain_labels = domain_labels(:);
    local_assert_nondegenerate(nodes, tetra);
    [domain_labels, original_ids] = local_remap_domain_labels(domain_labels);
end

function labels = local_labels_for_elements(label_src, n_elem)
    if isempty(label_src)
        labels = ones(n_elem, 1);
        return
    end
    labels = double(label_src(:));
    if isscalar(labels)
        labels = labels * ones(n_elem, 1);
        return
    end
    if numel(labels) ~= n_elem
        error('duneuro2zef:InvalidMesh', ...
            'Mesh has %d elements but %d tissue labels.', n_elem, numel(labels));
    end
end

function [mapped, original_ids] = local_remap_domain_labels(labels)
    original_ids = unique(labels);
    original_ids = original_ids(:)';
    mapped = zeros(size(labels));
    for i = 1:numel(original_ids)
        mapped(labels == original_ids(i)) = i;
    end
end

function [tetra, labels_tetra] = local_hex_to_tet(nodes, hexa, labels_hex)
    % zef_hexa_to_tetra expects DUNE / ndgrid corner order (1–4 bottom, 5–8
    % top). FieldTrip hex dumps often use VTK order (bottom 1 2 4 3). If
    % the DUNE split is degenerate, retry VTK column permutation.
    [tetra, labels_tetra] = zef_hexa_to_tetra(hexa, labels_hex);
    if ~local_has_degenerate(nodes, tetra)
        return
    end
    vtk = hexa(:, [1 2 4 3 5 6 8 7]);
    [tetra, labels_tetra] = zef_hexa_to_tetra(vtk, labels_hex);
    if local_has_degenerate(nodes, tetra)
        error('duneuro2zef:InvalidMesh', ...
            ['Hexahedral elements produced degenerate tetrahedra under both ' ...
            'DUNE and VTK vertex orderings.']);
    end
end

function local_assert_nondegenerate(nodes, tetra)
    if local_has_degenerate(nodes, tetra)
        error('duneuro2zef:InvalidMesh', ...
            'Imported tetrahedra include degenerate (zero-volume) elements.');
    end
end

function tf = local_has_degenerate(nodes, tetra)
    tf = false;
    if isempty(tetra) || size(tetra, 1) < 1
        return
    end
    vol = zef_tetra_volume(nodes, tetra, false);
    typical = median(abs(vol));
    if ~isfinite(typical) || typical <= 0
        typical = max(abs(vol));
    end
    if ~isfinite(typical) || typical <= 0
        tf = true;
        return
    end
    tf = any(abs(vol) < 1e-12 * typical);
end

function [payload, report] = local_fill_compartments(payload, raw, original_ids, report)
    labels = unique(payload.domain_labels);
    labels = labels(:)';
    name_ids = original_ids;
    if numel(name_ids) ~= numel(labels)
        name_ids = labels;
    end
    names = local_tissue_names(raw, name_ids);
    conductivity = local_find_conductivity(raw);
    payload.compartment_tags = cell(1, numel(labels));
    for i = 1:numel(labels)
        tag = sprintf('c%d', i);
        payload.compartment_tags{i} = tag;
        lab = labels(i);
        payload.([tag '_on']) = 1;
        payload.([tag '_visible']) = 1;
        payload.([tag '_sources']) = 0;
        payload.([tag '_priority']) = i;
        payload.([tag '_name']) = names{i};
        orig_lab = lab;
        if numel(name_ids) >= i
            orig_lab = name_ids(i);
        end
        payload.([tag '_sigma']) = local_sigma_for_label(conductivity, orig_lab, name_ids, i);
        tet_ind = find(payload.domain_labels == lab);
        try
            [tri, pts] = zef_surface_mesh(payload.tetra, payload.nodes, tet_ind);
            payload.([tag '_points']) = pts;
            payload.([tag '_triangles']) = tri;
        catch
            payload.([tag '_points']) = [];
            payload.([tag '_triangles']) = [];
            report.warnings{end+1} = sprintf( ...
                'Could not extract a surface for compartment %s (label %g).', tag, lab);
        end
    end
end

function names = local_tissue_names(raw, labels)
    names = arrayfun(@(k) sprintf('DUNEuro tissue %g', k), labels, 'UniformOutput', false);
    val = local_find_named(raw, {'tissuelabel', 'tissue_labels', 'tissue_names', ...
        'cond_names', 'compartment_names'}, 2);
    if isstring(val) || ischar(val)
        val = cellstr(val);
    end
    if iscell(val) && numel(val) == numel(labels)
        names = val(:)';
    elseif iscell(val) && numel(val) >= max(labels) && min(labels) >= 1
        names = val(labels);
        names = names(:)';
    end
end

function [pos, dir, model] = local_convert_sources(raw)
    pos = [];
    dir = [];
    model = [];
    dipoles = local_find_named(raw, {'dipoles', 'dipole'}, 2);
    if ~isempty(dipoles) && isnumeric(dipoles)
        if size(dipoles, 1) == 6
            pos = dipoles(1:3, :).';
            dir = dipoles(4:6, :).';
        elseif size(dipoles, 2) == 6
            pos = dipoles(:, 1:3);
            dir = dipoles(:, 4:6);
        elseif size(dipoles, 2) == 3
            pos = dipoles;
        elseif size(dipoles, 1) == 3
            pos = dipoles.';
        end
    end
    if isempty(pos)
        val = local_find_named(raw, {'source_positions', 'source_grid', 'sourcepos'}, 2);
        if ~isempty(val) && isnumeric(val)
            pos = local_as_n_by_k(val, 3, 'source positions');
        end
    end
    if ~isempty(pos) && ~all(isfinite(pos(:)))
        error('duneuro2zef:InvalidSources', 'Source coordinates contain non-finite values.');
    end

    sm = local_find_named(raw, {'source_model'}, 3);
    if isstruct(sm) && isfield(sm, 'type')
        sm = sm.type;
    end
    if ~isempty(sm)
        model = local_map_source_model(sm);
    end
end

function model = local_map_source_model(sm)
    model = [];
    key = lower(strtrim(char(string(sm))));
    key = strrep(strrep(strrep(key, ' ', ''), '.', ''), '_', '');
    switch key
        case {'whitney', '1'}
            model = core.types.ZefSourceModel.Whitney;
        case {'hdiv', 'h(div)', '2'}
            model = core.types.ZefSourceModel.Hdiv;
        case {'venant', 'stvenant', 'saintvenant', '3'}
            model = core.types.ZefSourceModel.StVenant;
        case {'continuouswhitney', '4'}
            model = core.types.ZefSourceModel.ContinuousWhitney;
        case {'continuoushdiv', '5'}
            model = core.types.ZefSourceModel.ContinuousHdiv;
        case {'continuousstvenant', '6'}
            model = core.types.ZefSourceModel.ContinuousStVenant;
        otherwise
            model = [];
    end
end

function measurements = local_find_measurements(raw)
    measurements = local_find_named(raw, {'measurements', 'avg'}, 1);
    if ~isempty(measurements) && ~isnumeric(measurements)
        measurements = [];
    end
end

function Y = local_orient_measurements(Y, n_electrodes)
    if isempty(n_electrodes) || n_electrodes <= 0
        return
    end
    if size(Y, 1) == n_electrodes
        return
    end
    if size(Y, 2) == n_electrodes && size(Y, 1) ~= n_electrodes
        Y = Y.';
        return
    end
    error('duneuro2zef:InvalidMeasurements', ...
        'Measurements size %s does not match %d sensors.', mat2str(size(Y)), n_electrodes);
end

function tensors = local_find_tensors(raw)
    tensors = local_find_named(raw, {'tensors', 'conductivity_tensors', 'sigma_tensors'}, 2);
    if isfield(raw, 'volume_conductor') && isstruct(raw.volume_conductor) ...
            && isfield(raw.volume_conductor, 'tensors')
        tensors = raw.volume_conductor.tensors;
    end
    if isempty(tensors) || ~isnumeric(tensors)
        tensors = [];
        return
    end
    if size(tensors, 1) == 6 || size(tensors, 1) == 9
        tensors = tensors.';
    end
end

function conductivity = local_find_conductivity(raw)
    conductivity = local_find_named(raw, {'conductivity', 'conductivities', 'sigma'}, 2);
    if ~isempty(conductivity) && isnumeric(conductivity)
        conductivity = conductivity(:);
    else
        conductivity = [];
    end
end

function [sigma, report] = local_pack_sigma(payload, conductivity, tensors, hex_converted, report)
    n_tet = size(payload.tetra, 1);
    sigma = zeros(n_tet, 1);
    labels = payload.domain_labels;
    orig = [];
    if isfield(payload, 'duneuro_import') && isfield(payload.duneuro_import, 'original_tissue_ids')
        orig = payload.duneuro_import.original_tissue_ids;
    end

    if ~isempty(conductivity) && numel(conductivity) == n_tet
        sigma(:, 1) = conductivity(:);
    elseif hex_converted && ~isempty(conductivity) && numel(conductivity) * 6 == n_tet
        sigma(:, 1) = repelem(conductivity(:), 6);
    else
        uniq = unique(labels);
        for i = 1:numel(uniq)
            lab = uniq(i);
            mask = labels == lab;
            orig_lab = lab;
            if numel(orig) >= i
                orig_lab = orig(i);
            end
            sigma(mask, 1) = local_sigma_for_label(conductivity, orig_lab, orig, i);
        end
    end

    if isempty(tensors)
        return
    end
    if size(tensors, 1) ~= n_tet && hex_converted && size(tensors, 1) * 6 == n_tet
        tensors = repelem(tensors, 6, 1);
    end
    if size(tensors, 1) ~= n_tet
        report.warnings{end+1} = sprintf( ...
            'Anisotropic tensors (%d rows) do not match %d tetrahedra; tensors were not applied.', ...
            size(tensors, 1), n_tet);
        return
    end
    packed = local_pack_tensor_rows(tensors);
    sigma = [sigma, zeros(n_tet, 1), packed];
end

function packed = local_pack_tensor_rows(tensors)
    % Zeffiro anisotropic columns are [σ11 σ22 σ33 σ12 σ13 σ23].
    % DUNEuro / SimBio 6-vectors are xx yy zz xy xz yz. 9-vectors are
    % row-major 3×3 (xx xy xz yx yy yz zx zy zz).
    if size(tensors, 2) == 6
        packed = tensors;
        return
    end
    if size(tensors, 2) == 9
        packed = tensors(:, [1, 5, 9, 2, 3, 6]);
        return
    end
    error('duneuro2zef:InvalidConductivity', ...
        'Conductivity tensors must have 6 or 9 columns, got %d.', size(tensors, 2));
end

function s = local_sigma_for_label(conductivity, lab, labels, idx)
    s = 0.33;
    if isempty(conductivity)
        return
    end
    if numel(conductivity) == numel(labels)
        s = conductivity(idx);
        return
    end
    if lab >= 1 && lab <= numel(conductivity)
        s = conductivity(lab);
        return
    end
    if lab >= 0 && (lab + 1) <= numel(conductivity)
        s = conductivity(lab + 1);
    end
end

function payload = local_mark_source_compartments(payload)
    if isempty(payload.compartment_tags)
        return
    end
    names = cell(1, numel(payload.compartment_tags));
    for i = 1:numel(payload.compartment_tags)
        tag = payload.compartment_tags{i};
        names{i} = lower(char(string(payload.([tag '_name']))));
        if any(contains(names{i}, {'brain', 'gray', 'grey', 'white', 'cortex', ...
                'hippocamp', 'thalam', 'cerebell'}))
            payload.([tag '_sources']) = 2;
        end
    end
    if ~isempty(payload.source_positions) && ~isempty(payload.nodes) && ~isempty(payload.tetra)
        centroids = (payload.nodes(payload.tetra(:, 1), :) ...
            + payload.nodes(payload.tetra(:, 2), :) ...
            + payload.nodes(payload.tetra(:, 3), :) ...
            + payload.nodes(payload.tetra(:, 4), :)) / 4;
        idx = local_nearest_rows(centroids, payload.source_positions);
        voted = unique(payload.domain_labels(idx));
        uniq = unique(payload.domain_labels);
        for i = 1:numel(uniq)
            if ismember(uniq(i), voted)
                tag = payload.compartment_tags{i};
                payload.([tag '_sources']) = 2;
            end
        end
        payload.brain_ind = find(ismember(payload.domain_labels, voted));
        payload.active_compartment_ind = payload.brain_ind;
    end
end

function [coords, report] = local_apply_length_unit(coords, raw, report)
    if isfield(report, 'unit_scale') && ~isempty(report.unit_scale)
        coords = coords * report.unit_scale;
        return
    end
    unit = local_find_named(raw, {'unit', 'units', 'length_unit'}, 2);
    scale = 1;
    unit_name = '';
    if ~isempty(unit)
        unit_name = lower(strtrim(char(string(unit))));
        switch unit_name
            case {'m', 'metre', 'meter', 'metres', 'meters', 'si'}
                scale = 1000;
            case {'cm', 'centimetre', 'centimeter'}
                scale = 10;
            case {'mm', 'millimetre', 'millimeter'}
                scale = 1;
        end
    else
        diag_len = local_bbox_diagonal(coords);
        if diag_len >= 0.05 && diag_len <= 0.5
            scale = 1000;
            unit_name = 'm (inferred from bounding-box diagonal)';
        elseif diag_len >= 50 && diag_len <= 500
            scale = 1;
            unit_name = 'mm (inferred from bounding-box diagonal)';
        else
            unit_name = 'unspecified; coordinates stored as given, location_unit=mm';
        end
    end
    report.unit_scale = scale;
    report.length_unit = unit_name;
    if scale ~= 1
        coords = coords * scale;
        report.warnings{end+1} = sprintf('Converted coordinates from %s to millimetres.', unit_name);
    end
end

function idx = local_nearest_rows(database, query)
    try
        idx = knnsearch(database, query);
    catch
        idx = zeros(size(query, 1), 1);
        for i = 1:size(query, 1)
            delta = database - query(i, :);
            [~, idx(i)] = min(sum(delta.^2, 2));
        end
    end
end

function d = local_bbox_diagonal(coords)
    if isempty(coords)
        d = NaN;
        return
    end
    lo = min(coords, [], 1);
    hi = max(coords, [], 1);
    d = norm(hi - lo);
end

function n = local_source_count(payload)
    if ~isempty(payload.source_positions)
        n = size(payload.source_positions, 1);
        return
    end
    if ~isempty(payload.L) && mod(size(payload.L, 2), 3) == 0
        n = size(payload.L, 2) / 3;
        return
    end
    n = size(payload.L, 2);
end

function local_require_something(payload)
    has_l = ~isempty(payload.L);
    has_mesh = ~isempty(payload.nodes);
    has_sens = ~isempty(payload.sensors);
    if ~(has_l || has_mesh || has_sens)
        error('duneuro2zef:EmptyProject', ...
            ['This file has no lead field, mesh, or electrodes that Zeffiro can use. ' ...
            'A DUNEuro transfer matrix alone is not a Zeffiro project.']);
    end
end

function local_consistency_checks(payload)
    if ~isempty(payload.L)
        if ~all(isfinite(payload.L(:)))
            error('duneuro2zef:InvalidLeadField', 'Converted lead field contains non-finite values.');
        end
        if size(payload.L, 1) < 1 || size(payload.L, 2) < 1
            error('duneuro2zef:InvalidLeadField', 'Converted lead field is empty.');
        end
    end
    if ~isempty(payload.sensors) && ~isempty(payload.L)
        if size(payload.L, 1) ~= size(payload.sensors, 1)
            error('duneuro2zef:SensorLeadFieldMismatch', ...
                'Internal error: L rows (%d) != electrodes (%d).', ...
                size(payload.L, 1), size(payload.sensors, 1));
        end
    end
    if ~isempty(payload.tetra)
        if size(payload.tetra, 2) ~= 4
            error('duneuro2zef:InvalidMesh', 'Tetrahedra must be N×4.');
        end
        if max(payload.tetra(:)) > size(payload.nodes, 1)
            error('duneuro2zef:InvalidMesh', 'Tetrahedron index exceeds node count.');
        end
        if numel(payload.domain_labels) ~= size(payload.tetra, 1)
            error('duneuro2zef:InvalidMesh', 'domain_labels length does not match tetra count.');
        end
    end
end

function A = local_as_n_by_k(A, k, name)
    if ~isnumeric(A)
        error('duneuro2zef:InvalidInput', '%s must be numeric.', name);
    end
    A = double(A);
    if size(A, 2) == k
        return
    end
    if size(A, 1) == k && size(A, 2) ~= k
        A = A.';
        return
    end
    error('duneuro2zef:InvalidInput', '%s must be N×%d or %d×N, got %s.', ...
        name, k, k, mat2str(size(A)));
end

function val = local_find_named(s, names, max_depth)
    val = [];
    if ~isstruct(s) || isempty(s)
        return
    end
    if nargin < 3
        max_depth = 2;
    end
    val = local_find_named_depth(s, names, max_depth, 0);
end

function val = local_find_named_depth(s, names, max_depth, depth)
    val = [];
    fn = fieldnames(s);
    for i = 1:numel(names)
        hit = fn(strcmpi(fn, names{i}));
        if ~isempty(hit)
            val = s.(hit{1});
            if ~isempty(val)
                return
            end
        end
    end
    if depth >= max_depth
        return
    end
    skip = {'duneuro_omitted_fields', 'duneuro_source_path'};
    for i = 1:numel(fn)
        if ismember(fn{i}, skip)
            continue
        end
        child = s.(fn{i});
        if isstruct(child) && isscalar(child)
            val = local_find_named_depth(child, names, max_depth, depth + 1);
            if ~isempty(val)
                return
            end
        end
    end
end

function val = local_first_existing_field(s, names)
    val = [];
    for i = 1:numel(names)
        if isfield(s, names{i}) && ~isempty(s.(names{i}))
            val = s.(names{i});
            return
        end
    end
end

function method = local_imaging_method_for(modality)
    method = 1;
    if strcmp(modality, 'MEG')
        method = 2;
    end
end
