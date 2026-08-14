function [c_table,c_points] = zef_parcellation_roi_embed(zef)
%ZEF_PARCELLATION_ROI_EMBED  Build parcellation tables from spherical ROIs on the source grid.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Optionally merges existing parcellation data, then appends an 'ROI'
%   atlas whose points are zef.source_positions within each ROI sphere
%   (center and radius from parcellation_roi_* fields).
%
%   [c_table, c_points] = zef_parcellation_roi_embed(zef)
%
%   Outputs
%     c_table, c_points - colortable and points cells including ROI entry.
%
%   See also zef_parcellation_default, zef_parcellation_roi_add.

c_table = cell(0);
c_points = cell(0);

if eval('zef.parcellation_merge')
    c_table = eval('zef.parcellation_colortable');
    c_points = eval('zef.parcellation_points');
else
    eval('zef.parcellation_selected = [];');
end

t_ind = length(c_table);

t_ind = t_ind + 1;

c_table{t_ind}{1} = 'ROI';

c_points_aux = [];
c_table{t_ind}{4} = [];
start_index = 0;
for i = 1 : size(zef.parcellation_roi_center,1)
c_points_aux_0 = zef.source_positions;
c_points_aux_1 = c_points_aux_0(find(sqrt(sum((c_points_aux_0-zef.parcellation_roi_center(i,:)).^2,2))<= zef.parcellation_roi_radius(i)),:);
c_points_aux = [c_points_aux ; [[start_index:start_index + size(c_points_aux_1,1)-1]' c_points_aux_1]];
start_index = start_index + size(c_points_aux_1,1); 
c_table{t_ind}{4} = [c_table{t_ind}{4} ; i*ones(size(c_points_aux_1,1),1)];
c_table{t_ind}{2}{i,1} = zef.parcellation_roi_name{i};
c_table{t_ind}{3}(i,1:3) = zef.parcellation_roi_color(i,:);
c_table{t_ind}{3}(i,5) =  i;
end

c_points{t_ind} = c_points_aux;
c_table{t_ind}{3}(:,1:3) = round(255*c_table{t_ind}{3}(:,1:3));
c_table{t_ind}{4} = c_table{t_ind}{4}(:);

end
