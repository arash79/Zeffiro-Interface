function zef = zef_strip_tool_burr_refresh(zef, message)
%ZEF_STRIP_TOOL_BURR_REFRESH  Fill the burr-hole list from the current lead.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Discovers compartments from the loaded model, drops rows whose tags
%   are gone, and shows each remaining radius and conductivity. Edit boxes
%   are filled only when the selected compartment changed or the caller
%   set zef.strip_tool.burr_fill_edits, so typing a tip point does not
%   wipe an uncommitted radius.
%
%   zef = zef_strip_tool_burr_refresh(zef)
%   zef = zef_strip_tool_burr_refresh(zef, message)
%
%   See also zef_strip_tool_update, zef_strip_burr_catalog.

if nargin < 2
    message = '';
end
if ~isstruct(zef) || ~isfield(zef, 'strip_tool') ...
        || ~isfield(zef.strip_tool, 'h_burr_list') ...
        || ~isgraphics(zef.strip_tool.h_burr_list)
    return
end

[zef, dropped] = zef_strip_burr_reconcile_all(zef);
if ~isempty(dropped) && isempty(message)
    message = sprintf( ...
        'Removed %d burr-hole row(s) because those compartments are no longer in the model: %s.', ...
        numel(unique(dropped)), strjoin(unique(dropped, 'stable'), ', '));
elseif ~isempty(dropped)
    message = sprintf('Removed stale compartments (%s). %s', ...
        strjoin(unique(dropped, 'stable'), ', '), message);
end

catalog = zef_strip_burr_catalog(zef);
popup = zef.strip_tool.h_burr_compartment;
prev = '';
if isgraphics(popup) && iscell(popup.UserData) && ~isempty(popup.UserData) ...
        && popup.Value >= 1 && popup.Value <= numel(popup.UserData)
    prev = popup.UserData{popup.Value};
end
if isempty(catalog.tag)
    labels = {'No compartments loaded'};
    tags = {''};
else
    labels = cell(1, numel(catalog.tag));
    for k = 1:numel(catalog.tag)
        labels{k} = local_popup_label(catalog, k);
    end
    tags = catalog.tag;
end
popup.String = labels(:);
popup.UserData = tags;
match = find(strcmp(tags, prev), 1);
if isempty(match)
    match = 1;
end
popup.Value = match;

key = [zef.current_sensors '_strip_cell'];
holes = zef_strip_burr_normalize([]);
if isfield(zef, key) && numel(zef.(key)) >= zef.strip_tool.current_strip
    strip = zef.(key){zef.strip_tool.current_strip};
    if isstruct(strip) && isfield(strip, 'burr_holes')
        holes = zef_strip_burr_normalize(strip.burr_holes);
    end
end

list = zef.strip_tool.h_burr_list;
if isempty(holes)
    list.String = {' '};
    list.Value = 1;
    list.UserData = {''};
else
    rows = cell(1, numel(holes));
    row_tags = cell(1, numel(holes));
    for i = 1:numel(holes)
        row_tags{i} = holes(i).compartment_tag;
        name = holes(i).compartment_tag;
        found = find(strcmp(catalog.tag, holes(i).compartment_tag), 1);
        if ~isempty(found)
            name = sprintf('%s [%s]', catalog.name{found}, holes(i).compartment_tag);
        end
        rows{i} = sprintf('%s  —  %g mm  —  %g S/m', ...
            name, holes(i).radius_mm, holes(i).conductivity);
    end
    list.String = rows(:);
    list.UserData = row_tags;
    if isempty(list.Value) || list.Value < 1 || list.Value > numel(rows)
        list.Value = 1;
    end
end

fill = isfield(zef.strip_tool, 'burr_fill_edits') && zef.strip_tool.burr_fill_edits;
selected = '';
if ~isempty(tags)
    selected = tags{popup.Value};
end
if fill || ~strcmp(prev, selected)
    zef = zef_strip_tool_burr_compartment(zef);
    zef.strip_tool.burr_fill_edits = false;
end

if isempty(message)
    message = ['Radius (mm) and replacement conductivity (S/m) are per compartment. ' ...
        'The cylinder follows the lead for the strip length. Apply to mesh writes sigma.'];
end
if isfield(zef.strip_tool, 'h_burr_status') && isgraphics(zef.strip_tool.h_burr_status)
    zef.strip_tool.h_burr_status.String = message;
end

end

function label = local_popup_label(catalog, index)

label = sprintf('%s [%s]', catalog.name{index}, catalog.tag{index});
if isfinite(catalog.sigma(index))
    label = sprintf('%s  now %g S/m', label, catalog.sigma(index));
end
if ~catalog.on(index)
    label = [label ' (off)'];
end

end
