function zef = zef_init_sensors_name_table(zef)
%ZEF_INIT_SENSORS_NAME_TABLE  Rebuild h_sensors_name_table from current sensor set.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Columns written: 1 Index, 2 Name (from *_name_list, the
%   contact index if that list is short), 3 Visible (from *_visible_list).
%   A complete contact list is displayed as stored. Hiding the set does
%   not rewrite it. An empty list means unspecified: the first refresh
%   while the set is visible stores one on-flag per point. Pads
%   *_color_table with the set color. nargout==0 → assignin base.
%
%   See also zef_update_sensors_name_table.
if nargin == 0
    zef = evalin('base','zef');
end

zef.aux_data_1 = cell(0);
zef.aux_data_2 = eval(['zef.' zef.current_sensors '_name_list']);
zef.aux_data_3 = eval(['zef.' zef.current_sensors '_points']);
for zef_i = length(zef.aux_data_2) + 1 : size(zef.aux_data_3,1)
    zef.aux_data_2{zef_i} = num2str(zef_i);
    eval(['zef.' zef.current_sensors '_name_list{' num2str(zef_i) '} =''' num2str(zef_i) ''';']);
end
n_points = size(zef.aux_data_3, 1);
set_visible = logical(eval(['zef.' zef.current_sensors '_visible']));
if isempty(set_visible)
    set_visible = false;
else
    set_visible = set_visible(1);
end
contact_visible = eval(['zef.' zef.current_sensors '_visible_list']);
contact_visible = contact_visible(:);
if isempty(contact_visible)
    if set_visible
        contact_visible = ones(n_points, 1);
        eval(['zef.' zef.current_sensors '_visible_list = contact_visible;']);
    else
        contact_visible = zeros(n_points, 1);
    end
elseif numel(contact_visible) < n_points
    if set_visible
        pad = ones(n_points - numel(contact_visible), 1);
    else
        pad = zeros(n_points - numel(contact_visible), 1);
    end
    contact_visible = [contact_visible; pad];
    eval(['zef.' zef.current_sensors '_visible_list = contact_visible;']);
end
zef.aux_data_4 = contact_visible;
if size(eval(['zef.' zef.current_sensors '_color_table']),1) < size(zef.aux_data_3,1)
    eval(['zef.' zef.current_sensors '_color_table = [' 'zef.' zef.current_sensors '_color_table ; zef.' zef.current_sensors '_color(ones(size(zef.' zef.current_sensors '_points,1)-size(zef.' zef.current_sensors '_color_table,1),1),:)];'])
end
for zef_i = 1 : size(zef.aux_data_3,1)
    zef.aux_data_1{zef_i,1} = zef_i;
    zef.aux_data_1{zef_i,2} = zef.aux_data_2{zef_i};
    if isempty(zef.aux_data_4)
        zef.aux_data_1{zef_i,3} = 1;
    else
        zef.aux_data_1{zef_i,3} = zef.aux_data_4(zef_i);
    end
end

zef.h_sensors_name_table.Data = zef.aux_data_1;

zef = rmfield(zef,{'aux_data_1','aux_data_2','aux_data_3','aux_data_4'});
clear zef_i;

if nargout == 0
    assignin('base','zef',zef);
end

end
