function zef_ui_ready(h)
%ZEF_UI_READY  Apply the shared theme and, when known, a window layout.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called after a tool, settings dialog, or plugin figure is built.
%   Theme is always applied. Named core windows also get a dedicated
%   layout pass so spacing matches the figure tool.
%
%   zef_ui_ready(h)
%
%   See also zef_ui_apply_theme, zef_ui_theme, zef_ui_place_window.

if nargin < 1 || isempty(h) || ~isgraphics(h) || ~isvalid(h)
    return
end

name = '';
try
    name = char(get(h, 'Name'));
catch
end
tag = '';
try
    tag = char(get(h, 'Tag'));
catch
end

laid_out = false;
is_fig_tool = (contains(name, 'Figure tool') && ~contains(name, 'axes popup')) ...
    || strcmp(tag, 'figure_tool');
is_menu = contains(name, 'Menu tool');
is_wait = strcmp(tag, 'progress_bar');
try
    if is_menu || is_wait
        laid_out = true;
    elseif is_fig_tool
        already = false;
        try
            already = zef_ui_is_unified(h);
        catch
        end
        if ~already
            zef_figure_tool_layout(h);
        end
        laid_out = true;
    elseif contains(name, 'Mesh visualization tool')
        zef_layout_mesh_visualization_tool(h);
        laid_out = true;
    elseif contains(name, 'Mesh tool')
        zef_layout_mesh_tool(h);
        laid_out = true;
    elseif contains(name, 'Segmentation tool')
        zef_layout_segmentation_tool(h);
        laid_out = true;
    elseif contains(lower(name), 'parcellation')
        zef_layout_parcellation_tool(h);
        laid_out = true;
    elseif contains(lower(name), 'dti conductivity')
        zef_layout_dti_tool(h);
        laid_out = true;
    elseif contains(lower(name), 'multi lead field')
        zef_layout_lf_bank(h);
        laid_out = true;
    elseif contains(lower(name), 'source tree')
        zef_layout_source_tree(h);
        laid_out = true;
    elseif contains(lower(name), 'leadfield processing') ...
            || contains(lower(name), 'lead field processing') ...
            || contains(lower(name), 'reconstruction tool')
        zef_layout_bank_tool(h);
        laid_out = true;
    elseif contains(lower(name), 'nse tool')
        zef_layout_nse_tool(h);
        laid_out = true;
    elseif contains(lower(name), 'filter tool')
        zef_layout_filter_tool(h);
        laid_out = true;
    elseif contains(lower(name), 'find synthetic source') ...
            && ~contains(lower(name), 'legacy') && ~contains(lower(name), 'eit') ...
            && ~contains(lower(name), 'patch') && ~contains(lower(name), 'roi') ...
            && ~contains(lower(name), 'gravity')
        zef_layout_fss(h);
        laid_out = true;
    elseif local_is_form_app(name)
        zef_layout_form_dialog(h);
        laid_out = ~isempty(findall(h, 'Tag', 'zef_ui_root'));
        if ~laid_out
            zef_layout_guide_window(h);
            laid_out = true;
        end
    elseif (contains(lower(name), 'settings') || contains(lower(name), 'profile') ...
            || contains(lower(name), 'options')) && ~contains(lower(name), 'tool') ...
            && ~contains(lower(name), 'gmm') && ~contains(lower(name), 'mixture')
        if ~isempty(findall(h, 'Type', 'uitable'))
            zef_layout_table_dialog(h);
        else
            zef_layout_form_dialog(h);
        end
        laid_out = true;
    elseif contains(lower(name), 'export') ...
            && numel(findall(h, 'Type', 'uitable')) == 1 ...
            && numel(findall(h, 'Type', 'uibutton')) <= 4 ...
            && numel(findall(h, 'Type', 'uitree')) == 0 ...
            && ~contains(lower(name), 'tool') && ~contains(name, 'Figure tool')
        zef_layout_table_dialog(h);
        laid_out = true;
    elseif local_should_form_layout(h)
        zef_layout_form_dialog(h);
        laid_out = true;
    elseif ~is_fig_tool && ~strcmp(tag, 'progress_bar')
        zef_layout_guide_window(h);
        laid_out = true;
    end
catch
    laid_out = false;
end
if ~laid_out && ~is_fig_tool && ~is_menu && ~is_wait
    try
        zef_layout_guide_window(h);
    catch
    end
end

zef_ui_apply_theme(h);
try
    zef_ui_polish_window(h);
catch
end

is_unified = strcmp(tag, 'figure_tool') && zef_ui_is_unified(h);
try
    % Layouts already chose a content-based size and stored ZefMinSize.
    % Do not inflate those windows back to a generic 240 px floor.
    if ~is_menu && ~is_wait && ~is_unified && ~isappdata(h, 'ZefMinSize')
        fig_pos = h.Position;
        if numel(fig_pos) >= 4 && fig_pos(3) < 360
            h.Position(3) = 360;
        end
        if numel(fig_pos) >= 4 && fig_pos(4) < 180
            h.Position(4) = 180;
        end
    end
catch
end

if ~is_menu && ~is_wait && ~is_unified && isappdata(h, 'ZefMinSize')
    try
        mins = getappdata(h, 'ZefMinSize');
        zef_ui_bind_min_size(h, mins(1), mins(2));
        zef_ui_adapt_grid(h);
    catch
    end
end

if contains(name, 'ZEFFIRO Interface') || strcmp(tag, 'progress_bar') ...
        || contains(lower(name), 'zeffiro')
    try
        zef_window_manager('standalone', h);
    catch
    end
end

try
    zef_ui_place_window(h);
catch
end

try
    setappdata(h, 'ZefUiThemed', true);
catch
end
try
    zef_ui_interact(h);
catch
end

end

function tf = local_is_form_app(name)

tf = false;
try
    nm = lower(char(name));
catch
    return
end
needles = {'sesame', 'hierarchical l1', 'l1/l2', 'rap-music', ...
    'gmm plot', 'gmm modeling', 'gm modeling', 'beamformer', ...
    'kalman', 'classical sparse', 'music', 'dipole scan', ...
    'gaussian mixture model (jl)', 'gaussian mixture model'};
for i = 1:numel(needles)
    if contains(nm, needles{i})
        if contains(nm, 'tool') && contains(needles{i}, 'gaussian mixture')
            continue
        end
        tf = true;
        return
    end
end

end

function tf = local_should_form_layout(h)

tf = false;
try
    if ~matlab.ui.internal.isUIFigure(h)
        return
    end
catch
    return
end
if ~isempty(findall(h, 'Type', 'uitable')) || ~isempty(findall(h, 'Type', 'uitree')) ...
        || ~isempty(findall(h, 'Type', 'uilistbox')) || ~isempty(findall(h, 'Type', 'uiaxes'))
    return
end
if numel(findall(h, 'Type', 'uitextarea')) > 1
    return
end
if numel(findall(h, 'Type', 'uimenu')) > 4
    return
end
if numel(findall(h, 'Type', 'uibutton')) > 6
    return
end
name = '';
try
    name = lower(char(h.Name));
catch
end
skip = {'workbench', 'data bank', 'databank', 'filter tool', 'nse tool', ...
    'dti', 'mixture', 'leadfield', 'lead field processing', 'reconstruction tool', ...
    'source tree', 'strip tool', 'topography', ...
    'parcellation', 'mesh tool', 'mesh visualization', ...
    'preconditioned', 'relaxation'};
for i = 1:numel(skip)
    if contains(name, skip{i})
        return
    end
end
n_lab = numel(findall(h, 'Type', 'uilabel'));
n_fld = numel(findall(h, 'Type', 'uieditfield')) ...
    + numel(findall(h, 'Type', 'uinumericeditfield')) ...
    + numel(findall(h, 'Type', 'uidropdown')) ...
    + numel(findall(h, 'Type', 'uitextarea'));
if n_lab < 3 || n_fld < 3 || n_fld > 28
    return
end
tf = true;

end
