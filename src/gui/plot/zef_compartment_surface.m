function [points, triangles] = zef_compartment_surface(zef, compartment_tag)
%ZEF_COMPARTMENT_SURFACE  Vertices and triangles of one compartment.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [points, triangles] = zef_compartment_surface(zef, compartment_tag)
%
%   Uses zef.reuna_p / reuna_t when process_meshes has registered the
%   tag, otherwise the compartment's stored points and triangles.

points = [];
triangles = [];
if isfield(zef, 'reuna_type') && isfield(zef, 'reuna_p') && isfield(zef, 'reuna_t')
    for surface_index = 1:size(zef.reuna_type, 1)
        if size(zef.reuna_type, 2) >= 4 && strcmp(char(string(zef.reuna_type{surface_index, 4})), compartment_tag)
            points = zef.reuna_p{surface_index};
            triangles = zef.reuna_t{surface_index};
            return
        end
    end
end
point_field = [compartment_tag '_points'];
triangle_field = [compartment_tag '_triangles'];
if isfield(zef, point_field) && isfield(zef, triangle_field)
    points = zef.(point_field);
    triangles = zef.(triangle_field);
end
end
