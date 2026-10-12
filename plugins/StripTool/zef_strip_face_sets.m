function [body, active, inactive] = zef_strip_face_sets(zef, compartment_tag, points, triangles)
%ZEF_STRIP_FACE_SETS  Split a shaft compartment into body and contact faces.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [body, active, inactive] = zef_strip_face_sets(zef, compartment_tag, points, triangles)
%
%   When the drawn triangulation is still the embedded shaft, contact
%   rows are those of the cylinder model. A later remesh is classified
%   again after the inverse shaft transform. Other compartments are
%   returned as a single body. Does not write zef.
%
%   See also zef_strip_contact_indices, zef_plot_compartment_mesh.

body = triangles;
active = zeros(0, 3);
inactive = zeros(0, 3);
strip_struct = zef_strip_from_compartment(zef, compartment_tag);
if isempty(strip_struct)
    return
end
[active_index, inactive_index] = local_indices(strip_struct, points, triangles);
if isempty(active_index) && isempty(inactive_index)
    return
end
active_index = unique(active_index(:));
inactive_index = unique(inactive_index(:));
active_index = active_index(active_index >= 1 & active_index <= size(triangles, 1));
inactive_index = inactive_index(inactive_index >= 1 & inactive_index <= size(triangles, 1));
if isempty(active_index) && isempty(inactive_index)
    return
end
active = triangles(active_index, :);
inactive = triangles(inactive_index, :);
keep = true(size(triangles, 1), 1);
keep([active_index; inactive_index]) = false;
body = triangles(keep, :);
end

function [active_index, inactive_index] = local_indices(strip_struct, points, triangles)

active_index = zeros(0, 1);
inactive_index = zeros(0, 1);
if ~isfield(strip_struct, 'triangles') || isempty(strip_struct.triangles) || isempty(strip_struct.triangles{1})
    return
end
if size(strip_struct.triangles{1}, 1) == size(triangles, 1)
    [active_index, inactive_index] = zef_strip_contact_indices(strip_struct);
    return
end
local_strip = strip_struct;
local_strip.encapsulation_on = 0;
local_strip.points = {points};
local_strip.triangles = {triangles};
local_strip.points = zef_strip_coordinate_transform(local_strip, 'reverse');
local_strip.triangles = {triangles};
[active_index, inactive_index] = zef_strip_contact_indices(local_strip);
end
