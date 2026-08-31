function [electrode_struct] = zef_electrode_struct(sensors_attached_volume)
%ZEF_ELECTRODE_STRUCT  Boundary edges of each attached CEM electrode patch.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   sensors_attached_volume must be N×4: [electrode_index, n1, n2, n3]
%   (triangle vertices on the skin). For each electrode index 1:max(col1),
%   unique interior edges (appear twice) are dropped; remaining edges are
%   the patch boundary. Used by zef_smoothing_step when attached CEM
%   patches need their boundary nodes. Non-4-column input → [].
%
%   electrode_struct(i).triangles, .edges, .nodes
%
%   See also zef_attach_sensors_volume, zef_smoothing_step.

electrode_struct = [];

if size(sensors_attached_volume,2) == 4

    for i = 1 : max(sensors_attached_volume(:,1))

        sensor_triangles = sensors_attached_volume(find(sensors_attached_volume(:,1)==i),2:4);
        sensor_edges_aux = [sensor_triangles(:,[1 2]); sensor_triangles(:,[2 3]); sensor_triangles(:,[3 1])];
        sensor_edges_aux = sortrows(sort(sensor_edges_aux,2));
        is_not_on_boundary = find(sum(abs(sensor_edges_aux(1:end-1,:) - sensor_edges_aux(2:end,:)),2)==0);
        is_not_on_boundary = [is_not_on_boundary ; is_not_on_boundary + 1];
        is_on_boundary = setdiff([1:size(sensor_edges_aux,1)]',is_not_on_boundary);
        electrode_struct(i).edges = sensor_edges_aux(is_on_boundary,:);
        electrode_struct(i).nodes = unique(electrode_struct(i).edges);
        electrode_struct(i).triangles = sensor_triangles;

    end

end
end
