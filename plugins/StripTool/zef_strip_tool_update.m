function zef = zef_strip_tool_update(zef)
%ZEF_STRIP_TOOL_UPDATE  Widgets → current strip_cell; rebuild the HTML strip list.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_strip_tool_update(zef)
%
%   Reads tip, orientation, model, impedance, lengths, encapsulation
%   into <current_sensors>_strip_cell{current_strip}. List colors
%   Tentative orange / Embedded green. Called from almost every edit
%   Callback. Does not write compartments.
%
%   See also zef_strip_tool_init.

struct_aux = zef.([zef.current_sensors '_strip_cell']){zef.strip_tool.current_strip};

struct_aux.tip_point = [str2num(zef.strip_tool.h_tip_point_1.String) ; ...
    str2num(zef.strip_tool.h_tip_point_2.String) ; ...
    str2num(zef.strip_tool.h_tip_point_3.String) ];

struct_aux.encapsulation_shift = [str2num(zef.strip_tool.h_encapsulation_shift_1.String) ; ...
    str2num(zef.strip_tool.h_encapsulation_shift_2.String) ; ...
    str2num(zef.strip_tool.h_encapsulation_shift_3.String) ];

struct_aux.orientation_axis{1} = [str2num(zef.strip_tool.h_orientation_axis_1.String) ; ...
    str2num(zef.strip_tool.h_orientation_axis_2.String) ; ...
    str2num(zef.strip_tool.h_orientation_axis_3.String) ];

struct_aux.orientation_axis{2} = [str2num(zef.strip_tool.h_encapsulation_orientation_axis_1.String) ; ...
    str2num(zef.strip_tool.h_encapsulation_orientation_axis_2.String) ; ...
    str2num(zef.strip_tool.h_encapsulation_orientation_axis_3.String) ];

struct_aux.strip_model = zef.strip_tool.h_strip_model.Value;
struct_aux.strip_impedance = str2num(zef.strip_tool.h_strip_impedance.String);
struct_aux.strip_conductivity = str2num(zef.strip_tool.h_strip_conductivity.String);
struct_aux.encapsulation_conductivity = str2num(zef.strip_tool.h_encapsulation_conductivity.String);
struct_aux.encapsulation_on = zef.strip_tool.h_encapsulation_on.Value;
struct_aux.strip_angle = str2num(zef.strip_tool.h_strip_angle.String);
struct_aux.strip_tag = zef.strip_tool.h_strip_tag.String;

struct_aux.strip_length = str2num(zef.strip_tool.h_strip_length.String);
struct_aux.encapsulation_length = str2num(zef.strip_tool.h_encapsulation_length.String);
struct_aux.encapsulation_thickness = str2num(zef.strip_tool.h_encapsulation_thickness.String);
struct_aux.strip_n_sectors = str2num(zef.strip_tool.h_strip_n_sectors.String);

if not(isfield(struct_aux,'strip_status'))
struct_aux.strip_status = 'Tentative';
end

zef.([zef.current_sensors '_strip_cell']){zef.strip_tool.current_strip} = struct_aux;

cell_aux = zef.([zef.current_sensors '_strip_cell']);

names_aux = cell(0);
colors_aux = zeros(0, 3);

for i = 1 : length(cell_aux)

if isequal(cell_aux{i}.strip_status,'Tentative')
color_aux = [1 0.55 0];
elseif isequal(cell_aux{i}.strip_status,'Embedded')
    color_aux = [0.15 0.7 0.2];
else
    color_aux = [0.6 0.6 0.6];
end

if isequal(cell_aux{i}.encapsulation_on, 1)
    str_aux = 'On';
else
    str_aux = 'Off';
end

model_str = '';
try
    model_str = zef.strip_tool.h_strip_model.String{cell_aux{i}.strip_model};
catch
end
names_aux{i} = sprintf('ID: %s, Tag: %s, Model: %s, Status: %s, Encapsulation: %s', ...
    num2str(cell_aux{i}.strip_id), char(string(cell_aux{i}.strip_tag)), ...
    char(string(model_str)), char(string(cell_aux{i}.strip_status)), str_aux);
colors_aux(i, :) = color_aux;

end

zef_colored_list('set', zef.strip_tool.h_strip_list, names_aux, colors_aux);
if isfield(zef.strip_tool, 'current_strip') && ~isempty(zef.strip_tool.current_strip)
    zef_colored_list('value', zef.strip_tool.h_strip_list, zef.strip_tool.current_strip);
end

end
