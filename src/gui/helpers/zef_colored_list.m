function varargout = zef_colored_list(action, varargin)
%ZEF_COLORED_LIST  Named list with per-row color swatches (old and new MATLAB).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Pre-R2025a uicontrol listboxes rendered undocumented Java HTML, which
%   Zeffiro used for color chips. R2025a+ WebGL listboxes and uitables show
%   row rules and oversized type. This helper keeps HTML listboxes on older
%   MATLAB and uses a compact uihtml list from R2025a (uitable fallback).
%
%   h = zef_colored_list('create', parent, position, tag)
%   h = zef_colored_list('create', parent, position, tag, Name, Value)
%       Name-Value: 'Callback', 'Multiselect', 'AllowEmpty', 'ShowSwatches',
%       'Trigger' ('callback' | 'buttondown'),
%       'Backend' ('auto'|'html'|'uihtml'|'table')
%   zef_colored_list('set', h, names, colors)
%   zef_colored_list('set', h, names, colors, 'Markers', m, 'MarkerColors', c)
%   idx = zef_colored_list('value', h)
%   zef_colored_list('value', h, idx)
%   tf = zef_colored_list('html_supported')
%
%   See also uihtml, uitable, zef_update_fig_details.

if nargin < 1 || isempty(action)
    error('zef_colored_list:MissingAction', 'Action is required.');
end
action = lower(char(string(action)));

switch action
    case 'html_supported'
        varargout{1} = local_html_supported();

    case 'create'
        parent = varargin{1};
        position = varargin{2};
        tag = '';
        if numel(varargin) >= 3
            tag = char(string(varargin{3}));
        end
        nv = struct( ...
            'callback', '', ...
            'multiselect', false, ...
            'allowempty', false, ...
            'showswatches', true, ...
            'trigger', 'callback', ...
            'backend', 'auto');
        if numel(varargin) >= 4
            nv = local_nv(nv, varargin(4:end));
        end
        nv.multiselect = local_tf(nv.multiselect);
        nv.allowempty = local_tf(nv.allowempty);
        nv.showswatches = local_tf(nv.showswatches);
        nv.trigger = lower(char(string(nv.trigger)));
        nv.backend = lower(char(string(nv.backend)));
        varargout{1} = local_create(parent, position, tag, nv);

    case 'set'
        h = varargin{1};
        names = {};
        colors = zeros(0, 3);
        extra = struct('markers', {{}}, 'markercolors', zeros(0, 3));
        if numel(varargin) >= 2
            names = varargin{2};
        end
        if numel(varargin) >= 3
            colors = varargin{3};
        end
        if numel(varargin) >= 4
            extra = local_nv(extra, varargin(4:end));
        end
        local_set(h, names, colors, extra);

    case 'value'
        h = varargin{1};
        if numel(varargin) >= 2
            local_set_value(h, varargin{2});
            if nargout > 0
                varargout{1} = local_get_value(h);
            end
        else
            varargout{1} = local_get_value(h);
        end

    otherwise
        error('zef_colored_list:UnknownAction', 'Unknown action: %s', action);
end

end

function tf = local_html_supported()
% Java HTML in uicontrol listboxes works only before R2025a. From R2025a
% the WebGL listbox shows the tags as text, so create() uses uihtml.
persistent cached
if isempty(cached)
    rel = version('-release');
    year = sscanf(char(string(rel)), '%d');
    cached = isempty(year) || year < 2025;
end
tf = cached;
end

function nv = local_nv(nv, args)
for i = 1:2:numel(args)
    name = lower(strrep(char(string(args{i})), '_', ''));
    if i + 1 > numel(args)
        break
    end
    nv.(name) = args{i+1};
end
end

function tf = local_tf(v)
if ischar(v) || isstring(v)
    tf = any(strcmpi(char(string(v)), {'on', 'true', '1', 'yes'}));
else
    tf = logical(v);
    if isempty(tf)
        tf = false;
    else
        tf = tf(1);
    end
end
end

function kind = local_kind(backend)
% 'auto' → html before R2025a, uihtml after. 'table' is the last-resort
% fallback when uihtml construction throws (no Java HTML, no uihtml).
backend = lower(char(string(backend)));
if strcmp(backend, 'html')
    kind = 'html';
elseif strcmp(backend, 'table')
    kind = 'table';
elseif strcmp(backend, 'uihtml')
    kind = 'uihtml';
elseif local_html_supported()
    kind = 'html';
else
    kind = 'uihtml';
end
end

function ud = local_ud(nv)
ud = struct( ...
    'Value', [], ...
    'Callback', nv.callback, ...
    'Multiselect', nv.multiselect, ...
    'AllowEmpty', nv.allowempty, ...
    'ShowSwatches', nv.showswatches, ...
    'Trigger', nv.trigger, ...
    'Backend', nv.backend, ...
    'Suppress', false, ...
    'Names', {{}}, ...
    'Colors', zeros(0, 3), ...
    'Markers', {{}}, ...
    'MarkerColors', zeros(0, 3), ...
    'N', 0);
end

function u = local_parent_units(parent)

u = 'pixels';
try
    u = parent.Units;
catch
end

end

function h = local_create(parent, position, tag, nv)

ud = local_ud(nv);
kind = local_kind(nv.backend);
ud.Backend = kind;

% HTML backend: undocumented Java listbox. Trigger 'buttondown' is what
% the Figure-tool Compartments/Sensors lists use (click opens uisetcolor).
if strcmp(kind, 'html')
    h = uicontrol( ...
        'Parent', parent, ...
        'Style', 'listbox', ...
        'Units', local_parent_units(parent), ...
        'Position', position, ...
        'Visible', 'on', ...
        'Tag', tag, ...
        'Min', 0, ...
        'Max', 1, ...
        'String', {}, ...
        'Value', []);
    local_apply_listbox_limits(h, 0, ud);
    if ~isempty(nv.callback)
        if strcmp(nv.trigger, 'buttondown')
            h.ButtonDownFcn = nv.callback;
        else
            h.Callback = nv.callback;
        end
    end
    h.UserData = ud;
    return
end

if strcmp(kind, 'uihtml')
    try
        h = local_create_uihtml(parent, position, tag, ud);
        return
    catch
        ud.Backend = 'table';
    end
end

h = local_create_table(parent, position, tag, nv, ud);

end

function h = local_create_uihtml(parent, position, tag, ud)
units = 'pixels';
try
    units = parent.Units;
catch
end
panel_opts = { ...
    'Parent', parent, ...
    'Units', units, ...
    'Position', position, ...
    'BorderType', 'line', ...
    'BackgroundColor', [1 1 1], ...
    'Title', '', ...
    'Tag', [tag '_panel']};
try
    panel = uipanel(panel_opts{:}, 'BorderColor', [0.72 0.72 0.72]);
catch
    panel = uipanel(panel_opts{:}, ...
        'HighlightColor', [0.72 0.72 0.72], ...
        'ShadowColor', [0.72 0.72 0.72]);
end
h = uihtml(panel);
h.Tag = tag;
h.HTMLSource = local_uihtml_src();
h.UserData = ud;
h.DataChangedFcn = @(src, evt) local_uihtml_changed(src, evt); %#ok<NASGU>
panel.SizeChangedFcn = @(src, ~) local_fill_uihtml(src);
local_fill_uihtml(panel);
local_push_uihtml(h);
end

function local_fill_uihtml(panel)
if isempty(panel) || ~isvalid(panel)
    return
end
h = [];
ch = panel.Children;
for i = 1:numel(ch)
    if local_is_uihtml(ch(i))
        h = ch(i);
        break
    end
end
if isempty(h)
    return
end
old = '';
try
    old = panel.Units;
    panel.Units = 'pixels';
catch
end
box = panel.Position;
try
    box = panel.InnerPosition;
catch
end
if ~isempty(old)
    try
        panel.Units = old;
    catch
    end
end
h.Position = [0 0 max(1, box(3)) max(1, box(4))];
end

function h = local_create_table(parent, position, tag, nv, ud)
h = uitable(parent, ...
    'Units', local_parent_units(parent), ...
    'Position', position, ...
    'ColumnName', {}, ...
    'RowName', {}, ...
    'ColumnEditable', false, ...
    'ColumnWidth', {18, 180}, ...
    'RowStriping', 'off', ...
    'FontSize', 8, ...
    'FontWeight', 'normal', ...
    'Tag', tag, ...
    'Data', cell(0, 2));
try
    h.FontUnits = 'points';
catch
end
h.FontSize = 8;
try
    h.ColumnWidth = {16, '1x'};
catch
end
try
    h.SelectionType = 'row';
catch
end
try
    if nv.multiselect
        h.Multiselect = 'on';
    else
        h.Multiselect = 'off';
    end
catch
end
h.UserData = ud;
h.CellSelectionCallback = @(src, evt) local_table_select(src, evt);
end

function local_table_select(src, evt)
rows = [];
try
    if ~isempty(evt) && isprop(evt, 'Indices') && ~isempty(evt.Indices)
        rows = unique(evt.Indices(:, 1), 'stable');
    end
catch
end
ud = src.UserData;
if ~isstruct(ud)
    ud = struct('Value', [], 'Callback', '');
end
ud.Value = rows(:)';
src.UserData = ud;
if isempty(rows)
    return
end
local_run_callback(src, evt);
end

function local_uihtml_changed(src, ~)
ud = src.UserData;
idx = local_value_from_uihtml(src);
if ~isstruct(ud)
    ud = struct('Value', [], 'Callback', '', 'Suppress', false);
end
if isfield(ud, 'Suppress') && ud.Suppress
    ud.Value = idx;
    src.UserData = ud;
    return
end
prev = [];
if isfield(ud, 'Value')
    prev = ud.Value;
end
ud.Value = idx;
src.UserData = ud;
if isequal(idx, prev)
    return
end
local_run_callback(src, []);
end

function local_run_callback(src, evt)
ud = src.UserData;
cb = '';
if isstruct(ud) && isfield(ud, 'Callback')
    cb = ud.Callback;
end
if isempty(cb)
    return
end
try
    if isa(cb, 'function_handle')
        cb(src, evt);
    else
        evalin('base', char(string(cb)));
    end
catch
end
end

function local_set(h, names, colors, extra)

if isempty(h) || ~isgraphics(h) || ~isvalid(h)
    return
end

names = local_cellstr(names);
n = numel(names);
show_swatches = true;
ud = h.UserData;
if isstruct(ud) && isfield(ud, 'ShowSwatches')
    show_swatches = ud.ShowSwatches;
end
if show_swatches
    colors = local_colors(colors, n);
else
    colors = zeros(n, 3);
end
markers = {};
marker_colors = zeros(0, 3);
if isfield(extra, 'markers')
    markers = extra.markers;
end
if isfield(extra, 'markercolors')
    marker_colors = extra.markercolors;
end
markers = local_cellstr(markers);
if numel(markers) < n
    markers(end+1:n) = {''};
elseif numel(markers) > n
    markers = markers(1:n);
end
if isempty(marker_colors)
    marker_colors = zeros(n, 3);
else
    marker_colors = local_colors(marker_colors, n);
end
has_markers = any(~cellfun(@isempty, markers));

prev = local_get_value(h);

% Keep names/colors on UserData so 'value' and a later 'set' can restore
% the selection after String/HTML is rewritten.
if ~isstruct(ud)
    ud = struct();
end
ud.N = n;
ud.Names = names;
ud.Colors = colors;
ud.Markers = markers;
ud.MarkerColors = marker_colors;
h.UserData = ud;

if local_is_listbox(h)
    % Pre-R2025a: each row is an HTML chip + optional coloured marker
    % (parcellation V/X) + the plain name. Callers must not parse String.
    html = cell(1, n);
    for i = 1:n
        if ~show_swatches
            html{i} = names{i};
            continue
        end
        rgb = round(255 * colors(i, :));
        if has_markers && ~isempty(markers{i})
            mrgb = round(255 * marker_colors(i, :));
            html{i} = sprintf([ ...
                '<HTML><BODY>&nbsp <SPAN bgcolor="rgb(%d,%d,%d)">', ...
                ' &nbsp &nbsp &nbsp </SPAN> &nbsp ', ...
                '<SPAN style="color:rgb(%d,%d,%d)">%s</SPAN> &nbsp %s</BODY></HTML>'], ...
                rgb(1), rgb(2), rgb(3), mrgb(1), mrgb(2), mrgb(3), ...
                markers{i}, names{i});
        else
            html{i} = sprintf([ ...
                '<HTML><BODY>&nbsp <SPAN bgcolor="rgb(%d,%d,%d)">', ...
                ' &nbsp &nbsp &nbsp </SPAN> &nbsp &nbsp %s</BODY></HTML>'], ...
                rgb(1), rgb(2), rgb(3), names{i});
        end
    end
    if n == 0
        set(h, 'String', {});
    else
        set(h, 'String', html);
    end
    local_apply_listbox_limits(h, n, ud);
    local_restore_value(h, prev, n, ud);
    return
end

if local_is_uihtml(h)
    % R2025a+: push JSON through HTMLSource Data; the page renders chips.
    local_restore_value(h, prev, n, ud);
    return
end

cb = [];
try
    cb = h.CellSelectionCallback;
    h.CellSelectionCallback = [];
catch
end

data = cell(n, 2);
for i = 1:n
    data{i, 1} = ' ';
    if has_markers && ~isempty(markers{i})
        data{i, 2} = [' ' markers{i} '  ' names{i}];
    else
        data{i, 2} = [' ' names{i}];
    end
end
h.Data = data;

try
    removeStyle(h);
catch
end
if show_swatches
    for i = 1:n
        try
            addStyle(h, uistyle('BackgroundColor', colors(i, :)), 'cell', [i 1]);
        catch
        end
        if has_markers && ~isempty(markers{i})
            try
                addStyle(h, uistyle('FontColor', marker_colors(i, :)), 'cell', [i 2]);
            catch
            end
        end
    end
end

try
    h.CellSelectionCallback = cb;
catch
end
local_restore_value(h, prev, n, ud);

end

function colors = local_colors(colors, n)
if n <= 0
    colors = zeros(0, 3);
    return
end
if isempty(colors)
    colors = 0.85 * ones(n, 3);
    return
end
colors = double(colors);
if size(colors, 1) < n
    colors = [colors; 0.85 * ones(n - size(colors, 1), 3)];
elseif size(colors, 1) > n
    colors = colors(1:n, :);
end
if size(colors, 2) < 3
    colors(:, 3) = 0.85;
end
colors = min(1, max(0, colors(:, 1:3)));
end

function local_apply_listbox_limits(h, n, ud)
allow_empty = isfield(ud, 'AllowEmpty') && ud.AllowEmpty;
multi = isfield(ud, 'Multiselect') && ud.Multiselect;
if allow_empty
    h.Min = 0;
else
    h.Min = 1;
end
if multi
    h.Max = max(2, max(n, 1));
else
    h.Max = 1;
end
end

function local_restore_value(h, prev, n, ud)
allow_empty = isfield(ud, 'AllowEmpty') && ud.AllowEmpty;
if n <= 0
    local_set_value(h, []);
    return
end
prev = local_clamp(prev, n);
if isempty(prev)
    if allow_empty
        local_set_value(h, []);
    else
        local_set_value(h, 1);
    end
else
    local_set_value(h, prev);
end
end

function idx = local_clamp(idx, n)
idx = double(idx(:))';
idx = idx(isfinite(idx) & idx >= 1 & idx <= n);
idx = unique(round(idx), 'stable');
end

function names = local_cellstr(names)
if isempty(names)
    names = {};
    return
end
if ischar(names)
    names = {names};
elseif isstring(names)
    names = cellstr(names);
elseif ~iscell(names)
    names = cellstr(string(names));
end
names = names(:)';
for i = 1:numel(names)
    names{i} = char(string(names{i}));
end
end

function tf = local_is_listbox(h)
tf = false;
try
    tf = isprop(h, 'Style') && strcmpi(char(string(h.Style)), 'listbox');
catch
end
end

function tf = local_is_uihtml(h)
tf = false;
try
    tf = isa(h, 'matlab.ui.control.HTML') || strcmpi(char(string(h.Type)), 'uihtml');
catch
end
end

function n = local_n(h)
n = 0;
ud = h.UserData;
if isstruct(ud) && isfield(ud, 'N')
    n = ud.N;
end
if n > 0
    return
end
if local_is_listbox(h)
    try
        n = numel(get(h, 'String'));
    catch
        n = 0;
    end
    return
end
if local_is_uihtml(h)
    try
        st = local_decode(h.Data);
        n = numel(local_cellstr(st.names));
    catch
        n = 0;
    end
    return
end
try
    n = size(h.Data, 1);
catch
end
end

function idx = local_get_value(h)
idx = [];
if isempty(h) || ~isgraphics(h) || ~isvalid(h)
    return
end
if local_is_listbox(h)
    try
        idx = h.Value;
    catch
        idx = [];
    end
    idx = double(idx(:))';
    return
end
if local_is_uihtml(h)
    idx = local_value_from_uihtml(h);
    return
end
try
    sel = h.Selection;
    if ~isempty(sel)
        idx = unique(sel(:, 1), 'stable')';
        return
    end
catch
end
try
    ud = h.UserData;
    if isstruct(ud) && isfield(ud, 'Value')
        idx = ud.Value;
    end
catch
end
if isempty(idx)
    idx = [];
else
    idx = double(idx(:))';
end
end

function idx = local_value_from_uihtml(h)
idx = [];
try
    st = local_decode(h.Data);
    if isstruct(st) && isfield(st, 'value')
        idx = double(st.value(:))';
    end
catch
end
if isempty(idx)
    try
        ud = h.UserData;
        if isstruct(ud) && isfield(ud, 'Value')
            idx = double(ud.Value(:))';
        end
    catch
    end
end
if isempty(idx)
    idx = [];
end
end

function local_set_value(h, idx)
if isempty(h) || ~isgraphics(h) || ~isvalid(h)
    return
end
n = local_n(h);
idx = local_clamp(idx, n);
ud = h.UserData;
if ~isstruct(ud)
    ud = struct();
end
allow_empty = isfield(ud, 'AllowEmpty') && ud.AllowEmpty;
if isempty(idx) && ~allow_empty && n > 0
    idx = 1;
end
ud.Value = idx;
h.UserData = ud;
if local_is_listbox(h)
    try
        if isempty(idx)
            h.Value = [];
        else
            h.Value = idx;
        end
    catch
    end
    return
end
if local_is_uihtml(h)
    local_push_uihtml(h);
    return
end
try
    if isempty(idx)
        h.Selection = zeros(0, 2);
    else
        h.Selection = [idx(:), ones(numel(idx), 1)];
    end
catch
end
end

function local_push_uihtml(h)
ud = h.UserData;
if ~isstruct(ud)
    return
end
st = struct();
st.names = local_cellstr(ud.Names);
if isempty(ud.Colors)
    st.colors = {};
else
    st.colors = num2cell(ud.Colors, 2);
end
st.markers = local_cellstr(ud.Markers);
if isempty(ud.MarkerColors)
    st.markercolors = {};
else
    st.markercolors = num2cell(ud.MarkerColors, 2);
end
st.value = ud.Value;
if isempty(st.value)
    st.value = zeros(1, 0);
end
st.multiselect = double(isfield(ud, 'Multiselect') && ud.Multiselect);
st.allowempty = double(isfield(ud, 'AllowEmpty') && ud.AllowEmpty);
st.showswatches = 1;
if isfield(ud, 'ShowSwatches')
    st.showswatches = double(ud.ShowSwatches);
end
ud.Suppress = true;
h.UserData = ud;
try
    h.Data = jsonencode(st);
catch
end
ud.Suppress = false;
h.UserData = ud;
end

function st = local_decode(raw)
st = struct('names', {{}}, 'value', []);
if isempty(raw)
    return
end
if isstruct(raw)
    st = raw;
    return
end
txt = char(string(raw));
if isempty(txt)
    return
end
st = jsondecode(txt);
end

function src = local_uihtml_src()
src = [ ...
'<!DOCTYPE html><html><head><meta charset="utf-8"><style>' ...
'html,body{margin:0;padding:0;height:100%;background:#fff;}' ...
'#list,#list .row{font-family:Helvetica,Arial,sans-serif;font-size:11px;' ...
'color:#111;}' ...
'#list{height:100%;overflow-x:hidden;overflow-y:auto;background:#fff;user-select:none;padding:4px 2px;box-sizing:border-box;scrollbar-width:thin;}' ...
'#list::-webkit-scrollbar{width:8px;}' ...
'#list::-webkit-scrollbar-thumb{background:#c5cdd0;border-radius:4px;}' ...
'#list::-webkit-scrollbar-track{background:transparent;}' ...
'.row{margin:0;padding:3px 8px;border:0;line-height:18px;min-height:18px;' ...
'white-space:nowrap;cursor:default;}' ...
'.row:hover{background:#f3f3f3;}' ...
'.row.sel{background:#d7e8ea;}' ...
'.chip{display:inline-block;width:9px;height:9px;margin-right:6px;' ...
'vertical-align:middle;border:1px solid rgba(0,0,0,.25);}' ...
'.mark{display:inline-block;min-width:10px;margin-right:4px;font-weight:700;}' ...
'</style></head><body><div id="list"></div><script>' ...
'function setup(htmlComponent){window.cc=htmlComponent;' ...
'htmlComponent.addEventListener("DataChanged",function(){render();});' ...
'render();}' ...
'function parse(){var raw=window.cc&&window.cc.Data;if(!raw)return {};' ...
'if(typeof raw==="string"){try{return JSON.parse(raw);}catch(e){return {};}}' ...
'return raw;}' ...
'function arr(x){if(x==null||x==="")return [];if(Array.isArray(x))return x;return [x];}' ...
'function rgbCss(c){if(!c||!c.length)return "rgb(200,200,200)";' ...
'var r=+c[0],g=+c[1],b=+c[2];if(r<=1&&g<=1&&b<=1){r=Math.round(r*255);g=Math.round(g*255);b=Math.round(b*255);}' ...
'return "rgb("+r+","+g+","+b+")";}' ...
'function esc(s){return String(s).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;");}' ...
'function render(){var d=parse();var names=arr(d.names);var colors=arr(d.colors);' ...
'var markers=arr(d.markers);var mcols=arr(d.markercolors);var sel=arr(d.value).map(Number);' ...
'var chips=d.showswatches!=0;var box=document.getElementById("list");if(!box)return;' ...
'var html="";for(var i=0;i<names.length;i++){var on=sel.indexOf(i+1)>=0;' ...
'html+="<div class=''row"+(on?" sel":"")+"'' data-i=''"+(i+1)+"''>";' ...
'if(chips){var c=colors[i]||[0.85,0.85,0.85];html+="<span class=''chip'' style=''background:"+rgbCss(c)+";''></span>";}' ...
'if(markers[i]){html+="<span class=''mark'' style=''color:"+rgbCss(mcols[i]||[0,0,0])+";''>"+esc(markers[i])+"</span>";}' ...
'html+=esc(names[i])+"</div>";}box.innerHTML=html;' ...
'box.onclick=function(ev){var row=ev.target;while(row&&row!==box&&!row.getAttribute("data-i"))row=row.parentNode;' ...
'if(!row||!row.getAttribute)return;clickRow(ev,+row.getAttribute("data-i"));};}' ...
'function clickRow(ev,idx){var d=parse();var multi=!!d.multiselect;var sel=arr(d.value).map(Number);' ...
'if(multi&&(ev.ctrlKey||ev.metaKey)){var p=sel.indexOf(idx);if(p>=0)sel.splice(p,1);else sel.push(idx);}' ...
'else if(multi&&ev.shiftKey&&sel.length){var a=sel[sel.length-1],b=idx,lo=Math.min(a,b),hi=Math.max(a,b);sel=[];for(var k=lo;k<=hi;k++)sel.push(k);}' ...
'else sel=[idx];d.value=sel;window.cc.Data=JSON.stringify(d);}' ...
'</script></body></html>'];
end
