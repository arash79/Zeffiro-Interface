function [triangles_out] = zef_triangles_2_sensor_boundary(zef,compartment_tag,triangles_in)
%ZEF_TRIANGLES_2_SENSOR_BOUND  Offset triangle indices onto a sensor boundary mesh stack.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Uses zef.<current_sensors>_boundary_cell to locate compartment_tag in
%   the stacked reuna_p surfaces and adds the cumulative vertex offset for
%   that boundary layer to triangles_in.
%
%   triangles_out = zef_triangles_2_sensor_boundary(zef, compartment_tag, triangles_in)
%
%   Inputs
%     zef             - session with boundary_cell and reuna_p.
%     compartment_tag - tag present in boundary_cell.
%     triangles_in    - triangle index array to rebase.
%
%   Output
%     triangles_out - offset triangles, or [] when compartment not in boundary_cell.
%
%   See also zef_attach_sensors_volume.

triangles_out = [];
    points_ind = []; 

    if isfield(zef,[zef.current_sensors '_boundary_cell'])

    boundary_cell = zef.([zef.current_sensors '_boundary_cell']);    
    points_ind = zeros(length(boundary_cell)+1,1);
    points_ind(1) = size(zef.reuna_p{end},1);

    end

for i = 1 : length(boundary_cell)

    compartment_tag_aux = boundary_cell{i};
    I = find(ismember(zef.compartment_tags,compartment_tag_aux),1);
    points_ind(i) = size(zef.reuna_p{I},1);

end

points_ind = cumsum(points_ind);
I = find(ismember(boundary_cell,compartment_tag),1);

if not(isempty(I))
triangles_out = points_ind(I-1)+triangles_in;
end

end
