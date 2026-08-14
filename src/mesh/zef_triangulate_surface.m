function [nodes, triangles] = zef_triangulate_surface(X, Y, Z, varargin)
%ZEF_TRIANGULATE_SURFACE  Turn a parametric surface grid into a triangle mesh.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   X, Y, Z are the same size as the arrays returned by MATLAB sphere,
%   ellipsoid, or meshgrid-based surf plots: neighbouring samples form
%   quadrilateral cells. surf2patch(...,'triangles') splits each cell into
%   two triangles. Optional max_faces then calls reducepatch to cap the
%   triangle count (useful before importing a synthetic surface as a
%   compartment).
%
%   Coordinates are left in whatever frame X,Y,Z already use. No conversion
%   to millimetres is performed here; apply the same unit as the rest of
%   the project before storing the result on zef.<tag>_points.
%
%   Companion zef_create_sphere builds a closed sphere by a different
%   path (delaunayTriangulation + reducepatch) and does not call this
%   function. This helper is for structured surf grids.
%
%   [nodes, triangles] = zef_triangulate_surface(X, Y, Z)
%   [nodes, triangles] = zef_triangulate_surface(X, Y, Z, max_faces)
%
%   Inputs
%     X, Y, Z     - matching 2-D arrays of sample coordinates.
%     max_faces   - optional. If > 0, reducepatch target face count.
%                   Default 0 means keep every triangle from surf2patch.
%
%   Outputs
%     nodes      - V-by-3 unique vertices from the patch.
%     triangles  - F-by-3 1-based faces into nodes.
%
%   See also zef_create_sphere, surf2patch, reducepatch.

max_faces = 0;
if not(isempty(varargin))
    max_faces = varargin{1};
end

% Structured grid → triangle faces; vertices may still contain duplicates
% from the original grid until reducepatch (when used) welds them.
patch_data = surf2patch(X,Y,Z,'triangles');
if max_faces > 0
    patch_data = reducepatch(patch_data,max_faces);
end
nodes = patch_data.vertices;
triangles = patch_data.faces;

end
