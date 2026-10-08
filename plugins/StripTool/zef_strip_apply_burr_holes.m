function [zef, report] = zef_strip_apply_burr_holes(zef, mode)
%ZEF_STRIP_APPLY_BURR_HOLES  Write lead-centered cylinder conductivities onto the mesh.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Each active burr-hole row is the intersection of a finite cylinder with
%   one compartment. The cylinder is concentric with that strip's lead
%   (same frame as zef_create_strip), starts at the tip, and runs for the
%   strip length. A tetrahedron belongs to the row when its domain label
%   is that compartment and its centroid lies in the cylinder. The domain
%   label is the active-compartment index used by mesh post-processing,
%   so disconnected pieces of one tissue are handled by the same test and
%   other compartments are not written.
%
%   The replacement value is the scalar the user entered, in S/m. It is
%   written to zef.sigma(:,1), which isotropic lead fields consume. When
%   zef.sigma already has the anisotropic packing in columns 3:8, those
%   columns become σ on the diagonal and zeros off it: a scalar
%   replacement is an isotropic tensor, not a rescaling of a DTI tensor.
%   Columns are never added. Zero is stored as zero.
%
%   A new cylindrical compartment would steal every tissue inside the
%   cylinder, because labeling keeps the highest-priority closed surface.
%   Boolean clipping of each anatomical surface is not what the mesher
%   consumes. Element conductivity is the representation the solvers read,
%   resolved at the existing tetrahedron size.
%
%   mode 'reapply' (default) first restores tetrahedra modified by the
%   previous call, then applies every strip whose burr_hole_on is set.
%   Turning the option off therefore removes the previous modification.
%   mode 'fresh' does not restore. Mesh post-processing rebuilds sigma
%   from compartment scalars and then calls 'fresh', so a remesh neither
%   keeps stale values nor requires a second manual apply.
%
%   The specification stays on the lead (burr_hole_on, burr_holes). It is
%   not a set of extra compartments. Solid-angle labeling keeps the first
%   surface that contains a node, so a cylinder inserted beside a tissue
%   is not the intersection of that tissue with the cylinder: it either
%   misses the tissue or claims every later tissue the cylinder crosses,
%   and a faceted cylinder is a poor inside-test. Both workflows therefore
%   derive the same element rule from the specification.
%
%   'fresh' is the mesh-generation path. Post-processing has just rebuilt
%   sigma from the compartment scalars, including when an older volume
%   mesh was still in the session. 'reapply' is the path for an existing
%   volume: restore the previous burr-hole elements, then write the
%   current specification. A radius smaller than zef.mesh_resolution is
%   not applied.
%
%   [zef, report] = zef_strip_apply_burr_holes(zef)
%   [zef, report] = zef_strip_apply_burr_holes(zef, mode)
%
%   See also zef_strip_burr_pick, zef_postprocess_fem_mesh, zef_strip_tool_embed.

if nargin < 2 || isempty(mode)
    mode = 'reapply';
end
mode = lower(char(string(mode)));
if ~ismember(mode, {'reapply', 'fresh'})
    error('zef:BurrHoleMode', 'mode must be ''reapply'' or ''fresh''.');
end

report = local_empty_report(mode);
if ~isstruct(zef)
    error('zef:BurrHole', 'A Zeffiro session struct is required.');
end

[zef, dropped] = zef_strip_burr_reconcile_all(zef);
if ~isempty(dropped)
    report.messages{end + 1} = sprintf( ...
        'Removed %d burr-hole row(s) whose compartments are no longer in the model: %s. They were not applied to another compartment.', ...
        numel(dropped), strjoin(dropped, ', '));
    warning('zef:BurrHoleRejected', '%s', report.messages{end});
end

mesh_state = local_mesh_state(zef);
if strcmp(mesh_state, 'absent')
    report.summary = ['No volumetric mesh is active. The burr-hole settings stay with the lead ' ...
        'and are included when you create or regenerate the FEM mesh from the surfaces.'];
    report.messages{end + 1} = report.summary;
    if strcmp(mode, 'reapply')
        report = local_add_dialog(report, 'info', report.summary);
    end
    zef.strip_burr_report = report;
    return
end
if strcmp(mesh_state, 'inconsistent')
    report.summary = ['Tetrahedra, domain labels, and sigma do not describe the same mesh. ' ...
        'Burr holes were not applied and existing conductivity was left unchanged.'];
    report.messages{end + 1} = report.summary;
    report = local_add_dialog(report, 'error', report.summary);
    warning('zef:BurrHoleMesh', '%s', report.summary);
    zef.strip_burr_report = report;
    return
end

n_restored = 0;
if strcmp(mode, 'fresh')
    zef.strip_burr_state = local_clear_state();
else
    [zef, n_restored, restore_note] = local_restore(zef);
    if ~isempty(restore_note)
        report.messages{end + 1} = restore_note;
        warning('zef:BurrHoleState', '%s', restore_note);
    end
end
report.n_restored = n_restored;

[specs, skip_messages, notices] = local_collect_specs(zef);
report.messages = [report.messages, skip_messages];
if ~isempty(notices)
    report.dialogs = [report.dialogs, notices];
end
for i = 1:numel(skip_messages)
    if contains(skip_messages{i}, 'was not replaced') || contains(skip_messages{i}, 'was not applied')
        warning('zef:BurrHoleRejected', '%s', skip_messages{i});
        report = local_add_dialog(report, 'warning', skip_messages{i});
    end
end

if isempty(specs)
    zef.strip_burr_state = local_clear_state();
    report = local_finish(report, [], [], [], zef);
    [zef, report] = local_invalidate_lead_field(zef, report);
    zef.strip_burr_report = report;
    return
end

catalog = zef_strip_burr_catalog(zef);
all_idx = zeros(0, 1);
all_val = zeros(0, 1);
all_entry = zeros(0, 1);
entries = local_empty_entries();
n_zero = 0;

strip_keys = unique([specs.strip_key], 'stable');
for key = strip_keys
    group = specs([specs.strip_key] == key);
    try
        local_nodes = zef_strip_lead_frame(group(1).geom, zef.nodes);
    catch ME
        report.messages{end + 1} = sprintf('Strip ID %s: %s', ...
            local_id_text(group(1).strip_id), ME.message);
        warning('zef:BurrHoleRejected', '%s', report.messages{end});
        continue
    end
    for s = 1:numel(group)
        spec = group(s);
        picked = zef_strip_burr_pick(local_nodes, zef.tetra, zef.domain_labels, ...
            spec.domain_id, spec.radius_mm, spec.length_mm);
        entry = local_entry(spec, picked);
        if spec.conductivity == 0 && ~isempty(picked.index)
            n_zero = n_zero + numel(picked.index);
        end
        entries(end + 1) = entry; %#ok<AGROW>
        if isempty(picked.index)
            report.messages{end + 1} = local_empty_message(spec, zef);
            if local_radius_unresolved(zef, spec.radius_mm)
                report = local_add_dialog(report, 'warning', report.messages{end});
            end
            continue
        end
        if local_radius_unresolved(zef, spec.radius_mm)
            report = local_add_dialog(report, 'warning', sprintf( ...
                ['%s: radius %g mm is smaller than the mesh resolution %g mm. ' ...
                'The conductivity was written on the tetrahedra whose centroids fall inside, ' ...
                'but the boundary is only resolved to the mesh size. ' ...
                'Create the FEM mesh again with a finer resolution for a closer cylinder.'], ...
                spec.compartment_name, spec.radius_mm, double(zef.mesh_resolution)));
        end
        n = numel(picked.index);
        all_idx = [all_idx; picked.index]; %#ok<AGROW>
        all_val = [all_val; repmat(spec.conductivity, n, 1)]; %#ok<AGROW>
        all_entry = [all_entry; repmat(numel(entries), n, 1)]; %#ok<AGROW>
    end
end

[final_idx, final_val, final_entry, n_overlap] = local_resolve_overlaps(all_idx, all_val, all_entry);
report.n_overlap = n_overlap;
if n_overlap > 0
    report.messages{end + 1} = sprintf( ...
        ['%d tetrahedra lie in more than one burr-hole cylinder. ' ...
        'The later row supplies the conductivity.'], n_overlap);
end

if ~isempty(final_idx)
    original_rows = zef.sigma(final_idx, :);
    zef.sigma(final_idx, 1) = final_val;
    if size(zef.sigma, 2) >= 8
        zef.sigma(final_idx, 3) = final_val;
        zef.sigma(final_idx, 4) = final_val;
        zef.sigma(final_idx, 5) = final_val;
        zef.sigma(final_idx, 6) = 0;
        zef.sigma(final_idx, 7) = 0;
        zef.sigma(final_idx, 8) = 0;
        report.messages{end + 1} = ...
            'Where sigma has tensor columns 3:8, the replacement is the isotropic tensor with this scalar on the diagonal.';
    end
    state.n_tetra = size(zef.sigma, 1);
    state.index = final_idx;
    state.original = original_rows;
    zef.strip_burr_state = state;
else
    zef.strip_burr_state = local_clear_state();
end

if ~isempty(entries) && ~isempty(final_entry)
    counts = accumarray(final_entry, 1, [numel(entries), 1]);
    for i = 1:numel(entries)
        entries(i).n_assigned = counts(i);
    end
end
report.entries = entries;
report = local_finish(report, entries, catalog, final_idx, zef);

if n_zero > 0
    zero_message = sprintf( ...
        ['Burr-hole conductivity 0 S/m was written exactly on %d tetrahedra. ' ...
        'Their stiffness contribution is zero, which can make the FEM system singular.'], ...
        n_zero);
    warning('zef:BurrHoleZeroConductivity', '%s', zero_message);
    report = local_add_dialog(report, 'warning', zero_message);
end

[zef, report] = local_invalidate_lead_field(zef, report);
zef.strip_burr_report = report;

end

function report = local_empty_report(mode)

report.mode = mode;
report.mesh_updated = false;
report.n_restored = 0;
report.n_overlap = 0;
report.messages = cell(1, 0);
report.summary = '';
report.entries = local_empty_entries();
report.dialogs = struct('severity', {}, 'message', {});
report.lead_field_cleared = false;

end

function entries = local_empty_entries()

entries = struct('sensor_field', {}, 'strip_id', {}, 'compartment_tag', {}, ...
    'compartment_name', {}, 'radius_mm', {}, 'conductivity', {}, ...
    'n_in_cylinder', {}, 'n_assigned', {}, 'max_radial_mm', {}, ...
    'min_excluded_radial_mm', {}, 'lead_radius_mm', {}, 'strip_length_mm', {}, ...
    'status', {}, 'detail', {});

end

function state = local_mesh_state(zef)

if ~isfield(zef, 'nodes') || ~isfield(zef, 'tetra') || isempty(zef.tetra) ...
        || isempty(zef.nodes)
    state = 'absent';
    return
end
ok = isfield(zef, 'sigma') && isfield(zef, 'domain_labels') ...
    && size(zef.tetra, 1) == size(zef.sigma, 1) ...
    && size(zef.domain_labels, 1) == size(zef.tetra, 1) ...
    && size(zef.nodes, 2) == 3 && size(zef.tetra, 2) == 4 ...
    && size(zef.sigma, 1) > 0;
if ok
    state = 'ready';
else
    state = 'inconsistent';
end

end

function [zef, n_restored, note] = local_restore(zef)

note = '';
n_restored = 0;
if ~isfield(zef, 'strip_burr_state') || ~isstruct(zef.strip_burr_state) ...
        || ~isfield(zef.strip_burr_state, 'index') || isempty(zef.strip_burr_state.index)
    zef.strip_burr_state = local_clear_state();
    return
end
st = zef.strip_burr_state;
match = isfield(st, 'n_tetra') && isfield(st, 'original') ...
    && size(zef.sigma, 1) == st.n_tetra ...
    && size(st.original, 1) == numel(st.index) ...
    && size(zef.sigma, 2) == size(st.original, 2) ...
    && all(st.index >= 1) && all(st.index <= st.n_tetra);
if ~match
    note = ['Stored burr-hole conductivity could not be restored because the mesh ' ...
        'no longer matches that record. Current element values were left in place, ' ...
        'then the active settings were applied on top. Re-run mesh post-processing ' ...
        'to rebuild compartment conductivities before relying on the result.'];
    zef.strip_burr_state = local_clear_state();
    return
end
zef.sigma(st.index, :) = st.original;
n_restored = numel(st.index);
zef.strip_burr_state = local_clear_state();

end

function state = local_clear_state()

state = struct('n_tetra', 0, 'index', zeros(0, 1), 'original', zeros(0, 0));

end

function [specs, messages, notices] = local_collect_specs(zef)

specs = struct('strip_key', {}, 'strip_id', {}, 'sensor_field', {}, ...
    'compartment_tag', {}, 'compartment_name', {}, 'domain_id', {}, ...
    'radius_mm', {}, 'conductivity', {}, 'length_mm', {}, ...
    'lead_radius_mm', {}, 'geom', {});
messages = cell(1, 0);
notices = struct('severity', {}, 'message', {});
catalog = zef_strip_burr_catalog(zef);
names = fieldnames(zef);
key = 0;
for i = 1:numel(names)
    if ~endsWith(names{i}, '_strip_cell') || ~iscell(zef.(names{i}))
        continue
    end
    cell_aux = zef.(names{i});
    for j = 1:numel(cell_aux)
        strip = cell_aux{j};
        if ~isstruct(strip) || ~isscalar(strip)
            continue
        end
        if ~isfield(strip, 'burr_hole_on') || isempty(strip.burr_hole_on) ...
                || double(strip.burr_hole_on(1)) == 0
            continue
        end
        if ~isfield(strip, 'burr_holes') || isempty(strip.burr_holes)
            continue
        end
        holes = zef_strip_burr_normalize(strip.burr_holes);
        if isempty(holes)
            continue
        end
        try
            geom = zef_strip_lead_axes(strip);
        catch ME
            messages{end + 1} = sprintf('Strip %d (%s): %s', j, names{i}, ME.message); %#ok<AGROW>
            continue
        end
        if ~(geom.strip_length > 0)
            messages{end + 1} = sprintf( ...
                'Strip ID %s: strip length must be greater than 0 mm. Its burr hole was not applied.', ...
                local_id_text(local_strip_id(strip, j))); %#ok<AGROW>
            continue
        end
        key = key + 1;
        lead_radius = NaN;
        if isfield(geom, 'strip_radius') && isscalar(geom.strip_radius) && isfinite(geom.strip_radius)
            lead_radius = double(geom.strip_radius);
        end
        for h = 1:numel(holes)
            [ok, notice] = zef_strip_burr_check(holes(h).radius_mm, holes(h).conductivity);
            tag = holes(h).compartment_tag;
            name = tag;
            domain_id = NaN;
            found = find(strcmp(catalog.tag, tag), 1);
            if ~isempty(found)
                name = sprintf('%s [%s]', catalog.name{found}, tag);
            end
            if ~ok
                messages{end + 1} = sprintf('%s, strip ID %s: %s', ...
                    name, local_id_text(local_strip_id(strip, j)), notice); %#ok<AGROW>
                continue
            end
            if isempty(found)
                messages{end + 1} = sprintf( ...
                    'Compartment tag %s is not in the current model. It was not applied to another compartment.', ...
                    tag); %#ok<AGROW>
                continue
            end
            if ~catalog.on(found) || ~isfinite(catalog.domain_label(found))
                messages{end + 1} = sprintf( ...
                    '%s is off, so it has no domain in the mesh. Nothing was written for it.', name); %#ok<AGROW>
                continue
            end
            spec.strip_key = key;
            spec.strip_id = local_strip_id(strip, j);
            spec.sensor_field = names{i};
            spec.compartment_tag = tag;
            spec.compartment_name = name;
            spec.domain_id = catalog.domain_label(found);
            spec.radius_mm = double(holes(h).radius_mm);
            spec.conductivity = double(holes(h).conductivity);
            spec.length_mm = geom.strip_length;
            spec.lead_radius_mm = lead_radius;
            spec.geom = geom;
            specs(end + 1) = spec; %#ok<AGROW>
            if ~isempty(notice)
                messages{end + 1} = sprintf('%s, strip ID %s: %s', ...
                    name, local_id_text(spec.strip_id), notice); %#ok<AGROW>
            end
            if isfinite(lead_radius) && spec.radius_mm <= lead_radius + 1e-9
                messages{end + 1} = sprintf( ...
                    ['%s: requested radius %g mm is not larger than the lead radius %g mm. ' ...
                    'Elements are still chosen only by this compartment and the cylinder. ' ...
                    'The lead volume is a separate domain only after the lead surface is meshed.'], ...
                    name, spec.radius_mm, lead_radius); %#ok<AGROW>
            end
        end
    end
end

end

function entry = local_entry(spec, picked)

entry.sensor_field = spec.sensor_field;
entry.strip_id = spec.strip_id;
entry.compartment_tag = spec.compartment_tag;
entry.compartment_name = spec.compartment_name;
entry.radius_mm = spec.radius_mm;
entry.conductivity = spec.conductivity;
entry.n_in_cylinder = numel(picked.index);
entry.n_assigned = numel(picked.index);
entry.max_radial_mm = picked.max_radial_mm;
entry.min_excluded_radial_mm = picked.min_excluded_radial_mm;
entry.lead_radius_mm = spec.lead_radius_mm;
entry.strip_length_mm = spec.length_mm;
if isempty(picked.index)
    entry.status = 'empty';
else
    entry.status = 'applied';
end
entry.detail = '';

end

function message = local_empty_message(spec, zef)

resolution = '';
if isfield(zef, 'mesh_resolution') && isscalar(zef.mesh_resolution) ...
        && isfinite(zef.mesh_resolution)
    resolution = sprintf(' Mesh resolution is %g mm.', double(zef.mesh_resolution));
end
message = sprintf( ...
    ['%s, strip ID %s: no tetrahedron centroid lies inside the cylinder ' ...
    '(radius %g mm, length %g mm from the tip along the lead). ' ...
    'The radius was not increased.%s'], ...
    spec.compartment_name, local_id_text(spec.strip_id), spec.radius_mm, ...
    spec.length_mm, resolution);

end

function [final_idx, final_val, final_entry, n_overlap] = local_resolve_overlaps(all_idx, all_val, all_entry)

final_idx = zeros(0, 1);
final_val = zeros(0, 1);
final_entry = zeros(0, 1);
n_overlap = 0;
if isempty(all_idx)
    return
end
order = (1:numel(all_idx))';
[~, perm] = sortrows([all_idx, order], [1, 2]);
idx_sorted = all_idx(perm);
val_sorted = all_val(perm);
entry_sorted = all_entry(perm);
boundary = [diff(idx_sorted) ~= 0; true];
final_idx = idx_sorted(boundary);
final_val = val_sorted(boundary);
final_entry = entry_sorted(boundary);
n_overlap = numel(all_idx) - numel(final_idx);
[final_idx, ord] = sort(final_idx);
final_val = final_val(ord);
final_entry = final_entry(ord);

end

function report = local_finish(report, entries, catalog, final_idx, zef) %#ok<INUSD>

if isempty(entries)
    entries = local_empty_entries();
end
report.entries = entries;
report.mesh_updated = report.n_restored > 0 || ~isempty(final_idx);
lines = report.messages;
if report.n_restored > 0 && isempty(final_idx)
    lines = [{sprintf('Restored conductivity on %d tetrahedra. No burr hole is active.', ...
        report.n_restored)}, lines];
elseif report.n_restored > 0
    lines = [{sprintf('Restored the previous burr-hole values on %d tetrahedra, then applied the current settings.', ...
        report.n_restored)}, lines];
end
for i = 1:numel(entries)
    if ~strcmp(entries(i).status, 'applied')
        continue
    end
    radial_note = '';
    if isfinite(entries(i).max_radial_mm)
        radial_note = sprintf(' Farthest included centroid is %0.4g mm from the axis.', ...
            entries(i).max_radial_mm);
    end
    gap_note = '';
    if isfinite(entries(i).min_excluded_radial_mm)
        gap_note = sprintf(' Nearest excluded centroid on the shaft span is %0.4g mm from the axis.', ...
            entries(i).min_excluded_radial_mm);
    end
    lines{end + 1} = sprintf( ...
        ['%s, strip ID %s: %d tetrahedra, radius %g mm, conductivity %g S/m, ' ...
        'lead length %g mm.%s%s'], ...
        entries(i).compartment_name, local_id_text(entries(i).strip_id), ...
        entries(i).n_assigned, entries(i).radius_mm, entries(i).conductivity, ...
        entries(i).strip_length_mm, radial_note, gap_note); %#ok<AGROW>
end
if ~report.mesh_updated && isempty(lines)
    if strcmp(report.mode, 'reapply')
        lines = {'No burr hole is active. Conductivity was not changed.'};
    end
elseif ~report.mesh_updated && strcmp(report.mode, 'reapply') && isempty(final_idx) ...
        && report.n_restored == 0 && isempty(entries)
    lines = [lines, {'No burr hole is active. Conductivity was not changed.'}];
end
report.messages = lines;
report.summary = local_compact_summary(report, entries);

end

function summary = local_compact_summary(report, entries)

lines = cell(1, 0);
if report.n_restored > 0 && isempty(entries)
    lines{end + 1} = sprintf('Restored %d tetrahedra. No burr hole is active.', report.n_restored); %#ok<AGROW>
end
saw_zero = false;
for i = 1:numel(entries)
    if strcmp(entries(i).status, 'applied')
        lines{end + 1} = sprintf('%s: %d tetrahedra, radius %g mm, %g S/m.', ...
            entries(i).compartment_name, entries(i).n_assigned, ...
            entries(i).radius_mm, entries(i).conductivity); %#ok<AGROW>
        if entries(i).conductivity == 0
            saw_zero = true;
        end
    elseif strcmp(entries(i).status, 'empty')
        lines{end + 1} = sprintf('%s: no tetrahedra inside radius %g mm. The radius was not increased.', ...
            entries(i).compartment_name, entries(i).radius_mm); %#ok<AGROW>
    end
end
if saw_zero
    lines{end + 1} = ['Conductivity 0 S/m was stored exactly. It adds nothing to the ' ...
        'stiffness matrix and can make the FEM system singular.']; %#ok<AGROW>
end
if report.n_overlap > 0
    lines{end + 1} = sprintf('%d tetrahedra lie in more than one cylinder. The later row wins.', ...
        report.n_overlap); %#ok<AGROW>
end
if isempty(lines) && ~isempty(report.messages)
    lines = report.messages(1:min(4, numel(report.messages)));
end
if isempty(lines)
    if strcmp(report.mode, 'reapply')
        lines = {'No burr hole is active. Conductivity was not changed.'};
    else
        summary = '';
        return
    end
end
summary = strjoin(lines, newline);

end

function tf = local_radius_unresolved(zef, radius_mm)

tf = false;
if ~isfield(zef, 'mesh_resolution') || isempty(zef.mesh_resolution)
    return
end
resolution = double(zef.mesh_resolution(1));
if ~isfinite(resolution) || resolution <= 0 || ~isfinite(radius_mm)
    return
end
tf = radius_mm < resolution;

end

function report = local_add_dialog(report, severity, message)

if ~isfield(report, 'dialogs') || isempty(report.dialogs)
    report.dialogs = struct('severity', {}, 'message', {});
end
report.dialogs(end + 1) = struct('severity', severity, 'message', message); %#ok<AGROW>

end

function [zef, report] = local_invalidate_lead_field(zef, report)

if ~report.mesh_updated || ~isfield(zef, 'L') || isempty(zef.L)
    return
end
zef.L = [];
if isfield(zef, 'inv_bg_data')
    zef.inv_bg_data = [];
end
report.lead_field_cleared = true;
note = 'The lead field was cleared because conductivity changed. Run the forward simulation again.';
report.messages{end + 1} = note;
if isempty(report.summary)
    report.summary = note;
else
    report.summary = [report.summary newline note];
end

end

function id = local_strip_id(strip, index)

id = index;
if isfield(strip, 'strip_id') && ~isempty(strip.strip_id) && isnumeric(strip.strip_id)
    id = strip.strip_id(1);
end

end

function text = local_id_text(id)

if isnumeric(id)
    text = num2str(id);
else
    text = char(string(id));
end

end
