function zef = zef_open_class_inverse(zef, spec)
%ZEF_OPEN_CLASS_INVERSE  Parameter dialog for a class inverter (zef_inverse_run).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Builds a themed uifigure whose controls map onto zef inv_* fields
%   (consumed by CommonInverseParameters.withPropertiesFromZef) and onto
%   MethodParams for the named registry id. Start calls zef_inverse_run.
%   Callers: zef_eloreta_window, zef_ukfnmm_window, zef_halpr_window,
%   zef_grouplasso_window, and the zef_*_class_window wrappers.
%
%   zef = zef_open_class_inverse(zef, spec)
%
%   spec.method_id   - registry id string (required), e.g. "eloreta"
%   spec.title       - window title stem; suffix " (class solver)" is added
%   spec.method_fields - optional cell of structs:
%       name, label, kind ('numeric'|'dropdown'|'checkbox'), value,
%       items (dropdown), scope ('method' → MethodParams, 'zef' → session)
%
%   Widget tags are zef_inv_<name>. Start requires zef.L and zef.measurements.
%   The figure is stored as zef.h_class_inverse_fig (not assignin unless
%   the caller does that).
%
%   See also zef_inverse_run, zef_eloreta_start, zef_class_inverse_method_fields,
%            utilities.cluster.inverse_method_registry.

if nargin == 0
    zef = evalin('base', 'zef');
end
if nargin < 2 || ~isstruct(spec) || ~isfield(spec, 'method_id')
    error('zef:ClassInverseSpec', 'spec.method_id is required.');
end
if ~isfield(spec, 'title') || isempty(spec.title)
    spec.title = char(string(spec.method_id));
end
if ~isfield(spec, 'method_fields') || isempty(spec.method_fields)
    spec.method_fields = {};
end

theme = zef_ui_theme();
fig = uifigure( ...
    'Name', ['ZEFFIRO Interface: ' spec.title ' (class solver)'], ...
    'Tag', ['zef_class_inverse_' char(string(spec.method_id))], ...
    'AutoResizeChildren', 'off', ...
    'Resize', 'on', ...
    'Color', theme.color.bg, ...
    'Visible', 'off');
try
    fig.Position = [100 100 720 420];
catch
end

common = local_common_fields(zef);
method_fields = spec.method_fields;
n_common = numel(common);
n_method = numel(method_fields);
two_col = (n_common + n_method) >= 14 || n_method >= 6;

root = uigridlayout(fig, [3 1], 'Tag', 'zef_ui_root', ...
    'Padding', [theme.space.pad theme.space.pad theme.space.pad theme.space.pad], ...
    'RowHeight', {'fit', '1x', 'fit'}, ...
    'ColumnWidth', {'1x'}, ...
    'RowSpacing', 8, ...
    'BackgroundColor', theme.color.bg);
title_lab = uilabel(root, 'Text', spec.title, ...
    'FontWeight', 'bold', 'FontSize', theme.font.sizeTitle, ...
    'FontColor', theme.color.text);
title_lab.Layout.Row = 1;
title_lab.Layout.Column = 1;

body = uigridlayout(root, [1 1 + double(two_col)], ...
    'Padding', [0 0 0 0], ...
    'ColumnSpacing', 12, ...
    'RowHeight', {'1x'}, ...
    'BackgroundColor', theme.color.bg);
if two_col
    body.ColumnWidth = {'1x', '1x'};
else
    body.ColumnWidth = {'1x'};
end
body.Layout.Row = 2;
body.Layout.Column = 1;
try
    body.Scrollable = 'on';
catch
end

widgets = struct();
n_left = n_common + n_method * double(~two_col);
left = local_section(body, theme, 'Shared parameters', n_left);
left.Layout.Column = 1;
row = 2;
for i = 1:n_common
    [widgets, row] = local_add_field(left, widgets, common{i}, zef, theme, row);
end
if two_col
    right = local_section(body, theme, 'Method parameters', n_method);
    right.Layout.Column = 2;
    row = 2;
    for i = 1:n_method
        [widgets, row] = local_add_field(right, widgets, method_fields{i}, zef, theme, row); %#ok<NASGU>
    end
else
    for i = 1:n_method
        [widgets, row] = local_add_field(left, widgets, method_fields{i}, zef, theme, row);
    end
end

actions = uigridlayout(root, [2 1], ...
    'Padding', [0 0 0 0], 'ColumnWidth', {'1x'}, ...
    'RowHeight', {'fit', 32}, ...
    'RowSpacing', 6, ...
    'BackgroundColor', theme.color.bg);
actions.Layout.Row = 3;
actions.Layout.Column = 1;
hint = uilabel(actions, 'Text', ['Class/cluster solver (zef_inverse_run). ' ...
        'This is not the Inverse-tools plugin algorithm. See docs/adr/ADR-002-dual-inverse-tracks.md.'], ...
    'FontColor', theme.color.textMuted, 'WordWrap', 'on');
hint.Layout.Row = 1;
hint.Layout.Column = 1;
btn_row = uigridlayout(actions, [1 3], ...
    'Padding', [0 0 0 0], 'ColumnWidth', {'1x', 120, '1x'}, ...
    'RowHeight', {32}, ...
    'BackgroundColor', theme.color.bg);
btn_row.Layout.Row = 2;
uilabel(btn_row, 'Text', '');
start_btn = uibutton(btn_row, 'Text', 'Start', ...
    'Tag', 'zef_inv_start', ...
    'BackgroundColor', theme.color.primary, 'FontColor', theme.color.primaryText);
start_btn.Layout.Column = 2;

ud = struct('spec', spec, 'widgets', widgets, 'fig', fig);
fig.UserData = ud;
start_btn.ButtonPushedFcn = @(src, evt) local_run(fig);

zef.h_class_inverse_fig = fig;
n_form = n_common + n_method;
if two_col
    n_form = max(n_common, n_method);
    need_w = 760;
else
    need_w = 560;
end
need_h = 52 + 28 + n_form * 34 + 88;
try
    zef_ui_apply_size(fig, need_w, need_h, max(480, round(0.88 * need_w)), ...
        max(280, min(need_h, round(0.92 * need_h))));
catch
end
try
    zef_ui_ready(fig);
catch
end
try
    drawnow;
    zef_ui_ensure_visible(fig);
catch
end
try
    fig.Visible = 'on';
    zef_ui_place_window(fig);
    zef_window_manager('raise', fig);
catch
end

end

function card = local_section(parent, theme, heading, n_fields)

n_fields = max(1, n_fields);
card = uigridlayout(parent, [n_fields + 2 2], ...
    'Padding', [8 8 8 8], ...
    'ColumnWidth', {188, '1x'}, ...
    'RowHeight', [{22}, repmat({28}, 1, n_fields), {'1x'}], ...
    'RowSpacing', 6, ...
    'ColumnSpacing', theme.space.gap, ...
    'BackgroundColor', theme.color.panel);
lab = uilabel(card, 'Text', heading, ...
    'FontWeight', 'bold', 'FontColor', theme.color.header);
lab.Layout.Row = 1;
lab.Layout.Column = [1 2];

end

function fields = local_common_fields(zef)

fields = { ...
    local_num('inv_snr', 'SNR (dB)', local_get(zef, 'inv_snr', 30)), ...
    local_num('number_of_frames', 'Number of frames', local_get(zef, 'number_of_frames', 1)), ...
    local_num('inv_sampling_frequency', 'Sampling frequency (Hz)', local_get(zef, 'inv_sampling_frequency', 1025)), ...
    local_num('inv_low_cut_frequency', 'Low-cut (Hz)', local_get(zef, 'inv_low_cut_frequency', 7)), ...
    local_num('inv_high_cut_frequency', 'High-cut (Hz)', local_get(zef, 'inv_high_cut_frequency', 9)), ...
    local_num('inv_time_1', 'Time start (s)', local_get(zef, 'inv_time_1', 0)), ...
    local_num('inv_time_2', 'Time window (s)', local_get(zef, 'inv_time_2', 0)), ...
    local_num('inv_time_3', 'Time step (s)', local_get(zef, 'inv_time_3', 0.001)), ...
    local_drop('normalize_data', 'Data normalization', ...
        {'Maximum entry', 'Maximum column norm', 'Average column norm', 'None'}, ...
        local_get(zef, 'normalize_data', 1))};

end

function f = local_num(name, label, value)

f = struct('name', name, 'label', label, 'kind', 'numeric', ...
    'value', value, 'items', {{}}, 'scope', 'zef');

end

function f = local_drop(name, label, items, value)

f = struct('name', name, 'label', label, 'kind', 'dropdown', ...
    'value', value, 'items', {items}, 'scope', 'zef');

end

function v = local_get(zef, name, default)

v = default;
if isstruct(zef) && isfield(zef, name) && ~isempty(zef.(name))
    v = zef.(name);
end

end

function [widgets, row] = local_add_field(form, widgets, spec, zef, theme, row)

if ~isfield(spec, 'scope') || isempty(spec.scope)
    spec.scope = 'method';
end
n_rows = 2;
try
    rh = form.RowHeight;
    n_rows = numel(rh);
catch
end
if row > n_rows
    extra = row - n_rows;
    form.RowHeight = [form.RowHeight, repmat({28}, 1, extra)];
end
lab = uilabel(form, 'Text', spec.label, 'FontColor', theme.color.text, ...
    'HorizontalAlignment', 'right', 'WordWrap', 'off');
lab.Layout.Row = row;
lab.Layout.Column = 1;
kind = 'numeric';
if isfield(spec, 'kind')
    kind = char(spec.kind);
end
h = [];
switch kind
    case 'dropdown'
        items = spec.items;
        h = uidropdown(form, 'Items', items, ...
            'BackgroundColor', theme.color.inputBg, 'FontColor', theme.color.text);
        val = spec.value;
        if isnumeric(val) && val >= 1 && val <= numel(items)
            h.Value = items{val};
        else
            sval = char(string(val));
            if any(strcmp(items, sval))
                h.Value = sval;
            else
                h.Value = items{1};
            end
        end
    case 'checkbox'
        h = uicheckbox(form, 'Text', '', 'Value', logical(spec.value));
    otherwise
        h = uieditfield(form, 'text', ...
            'Value', local_num2str(spec.value), ...
            'BackgroundColor', theme.color.inputBg, 'FontColor', theme.color.text);
end
h.Layout.Row = row;
h.Layout.Column = 2;
try
    h.Tag = ['zef_inv_' spec.name];
catch
end
widgets.(spec.name) = struct('handle', h, 'spec', spec);
row = row + 1;

end

function s = local_num2str(v)

if isstring(v) || ischar(v)
    s = char(string(v));
    return
end
if isempty(v)
    s = '';
    return
end
s = num2str(v(1));

end

function local_run(fig)

ud = fig.UserData;
spec = ud.spec;
widgets = ud.widgets;
try
    zef = evalin('base', 'zef');
catch
    uialert(fig, 'No Zeffiro session (zef) is in the base workspace.', spec.title);
    return
end
names = fieldnames(widgets);
method_params = struct();
for i = 1:numel(names)
    w = widgets.(names{i});
    val = local_read_widget(w);
        if strcmp(w.spec.scope, 'zef')
            if strcmp(w.spec.name, 'normalize_data')
                items = w.spec.items;
                idx = find(strcmp(items, char(string(val))), 1);
                if isempty(idx)
                    idx = 1;
                end
                zef.normalize_data = idx;
            else
                zef.(w.spec.name) = val;
            end
        else
            if isempty(val) && ~strcmp(w.spec.name, 'regularization_parameter')
                continue
            end
            if isfield(w.spec, 'kind') && strcmp(char(w.spec.kind), 'dropdown')
                val = string(val);
            end
            method_params.(w.spec.name) = val;
        end
end
if ~isfield(zef, 'L') || isempty(zef.L)
    uialert(fig, 'A lead field (zef.L) is required before inversion.', spec.title);
    return
end
if ~isfield(zef, 'measurements') || isempty(zef.measurements)
    uialert(fig, 'Measurements (zef.measurements) are required before inversion.', spec.title);
    return
end
assignin('base', 'zef', zef);
try
    [zef, run_result] = zef_inverse_run(zef, string(spec.method_id), ...
        'execution', 'local', 'MethodParams', method_params); %#ok<ASGLU>
    assignin('base', 'zef', zef);
catch err
    uialert(fig, err.message, spec.title);
end

end

function val = local_read_widget(w)

h = w.handle;
kind = 'numeric';
if isfield(w.spec, 'kind')
    kind = char(w.spec.kind);
end
switch kind
    case 'dropdown'
        val = h.Value;
    case 'checkbox'
        val = logical(h.Value);
    otherwise
        raw = strtrim(char(string(h.Value)));
        if isempty(raw)
            val = [];
        else
            num = str2double(raw);
            if isnan(num)
                val = raw;
            else
                val = num;
            end
        end
end

end
