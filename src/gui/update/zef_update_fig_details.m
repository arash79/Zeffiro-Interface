function zef = zef_update_fig_details(zef)
%ZEF_UPDATE_FIG_DETAILS  Refresh Figure-tool **Compartments:** / **Sensors:** / **Details:** lists.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Called at the end of zef_figure_tool and after Visualize
%   volume/surfaces. Does not redraw axes1.
%
%   **Sensors:** list (Tag='sensor_visible_color') — color swatches for
%   rows of current_sensors where *_visible_list is true.
%
%   **Compartments:** list (Tag='compartment_visible_color') — swatches
%   for tags with *_on and *_visible, reversed to match Segmentation-tool
%   row order. Click → zef_set_compartment_color.
%
%   **Details:** list (Tag='system_information') — node/tetra counts and
%   visualization settings as plain text.
%
%   nargout==0 → assignin('base','zef',zef).
%
%   See also zef_figure_tool, zef_colored_list, zef_set_compartment_color.
if nargin == 0
    zef = evalin('base','zef');
end

sensor_names = {};
sensor_colors = zeros(0, 3);
if isfield(zef, 'current_sensors') && ~isempty(zef.current_sensors) ...
        && isfield(zef, [zef.current_sensors '_points'])
    points = zef.([zef.current_sensors '_points']);
    vis_list = [];
    if isfield(zef, [zef.current_sensors '_visible_list'])
        vis_list = zef.([zef.current_sensors '_visible_list']);
    end
    name_list = {};
    if isfield(zef, [zef.current_sensors '_name_list'])
        name_list = zef.([zef.current_sensors '_name_list']);
    end
    color_table = [];
    if isfield(zef, [zef.current_sensors '_color_table'])
        color_table = zef.([zef.current_sensors '_color_table']);
    end
    if size(vis_list, 1) == size(points, 1)
        for i = 1:size(points, 1)
            if vis_list(i)
                nm = '';
                if numel(name_list) >= i
                    nm = char(string(name_list{i}));
                end
                rgb = [0.7 0.7 0.7];
                if size(color_table, 1) >= i
                    rgb = color_table(i, :);
                end
                sensor_names{end+1} = nm; %#ok<AGROW>
                sensor_colors(end+1, :) = rgb; %#ok<AGROW>
            end
        end
    end
end
if isfield(zef, 'h_sensor_visible_color') && isvalid(zef.h_sensor_visible_color)
    zef_colored_list('set', zef.h_sensor_visible_color, sensor_names, sensor_colors);
end

comp_names = {};
comp_colors = zeros(0, 3);
if isfield(zef, 'compartment_tags')
    for i = numel(zef.compartment_tags):-1:1
        tag = zef.compartment_tags{i};
        is_on = isfield(zef, [tag '_on']) && zef.([tag '_on']);
        is_vis = isfield(zef, [tag '_visible']) && zef.([tag '_visible']);
        if is_on && is_vis
            nm = tag;
            if isfield(zef, [tag '_name'])
                nm = char(string(zef.([tag '_name'])));
            end
            rgb = [0.7 0.7 0.7];
            if isfield(zef, [tag '_color'])
                rgb = zef.([tag '_color']);
            end
            comp_names{end+1} = nm; %#ok<AGROW>
            comp_colors(end+1, :) = rgb; %#ok<AGROW>
        end
    end
end
if isfield(zef, 'h_compartment_visible_color') && isvalid(zef.h_compartment_visible_color)
    zef_colored_list('set', zef.h_compartment_visible_color, comp_names, comp_colors);
end

zef.aux_field = {['Nodes: ' num2str(size(zef.nodes,1))],...
    ['Tetrahedra: ' num2str(size(zef.tetra,1))],...
    };

if eval('zef.on_screen') == 0
    zef.aux_field = [zef.aux_field, {'Visualization: '}];
end
if eval('zef.on_screen') == 1
    zef.aux_field = [zef.aux_field, {'Visualization: Volume'}];
end
if eval('zef.on_screen') == 2
    zef.aux_field = [zef.aux_field, {'Visualization: Surfaces'}];
end
if eval('zef.inv_scale') == 1
    zef.aux_field = [zef.aux_field, {'Scale: Logarithmic'}];
end
if eval('zef.inv_scale') == 2
    zef.aux_field = [zef.aux_field, {'Scale: Linear'}];
end
if eval('zef.inv_scale') == 3
    zef.aux_field = [zef.aux_field, {'Scale: Square root'}];
end
if eval('zef.source_direction_mode') == 1
    zef.aux_field = [zef.aux_field, {'Field basis: Cartesian'}];
end
if eval('zef.source_direction_mode') == 2
    zef.aux_field = [zef.aux_field, {'Field basis: Normal'}];
end
if eval('zef.source_direction_mode') == 3
    zef.aux_field = [zef.aux_field, {'Field basis: Mesh'}];
end
if eval('zef.reconstruction_type') == 1
    zef.aux_field = [zef.aux_field, {'Field: Amplitude'}];
end
if eval('zef.reconstruction_type') == 2
    zef.aux_field = [zef.aux_field, {'Field: Normal'}];
end
if eval('zef.reconstruction_type') == 3
    zef.aux_field = [zef.aux_field, {'Field: Tangential'}];
end
if eval('zef.reconstruction_type') == 4
    zef.aux_field = [zef.aux_field, {'Field: Normal (+)'}];
end
if eval('zef.reconstruction_type') == 5
    zef.aux_field = [zef.aux_field, {'Field: Normal (-)'}];
end
if eval('zef.reconstruction_type') == 6
    zef.aux_field = [zef.aux_field, {'Field: Value'}];
end
if eval('zef.reconstruction_type') == 7
    zef.aux_field = [zef.aux_field, {'Field: Amplitude smoothed'}];
end

if isfield(zef, 'h_system_information') && isvalid(zef.h_system_information)
    zef_colored_list('set', zef.h_system_information, zef.aux_field, []);
end
zef = rmfield(zef,'aux_field');

if nargout == 0
    assignin('base','zef',zef);
end
