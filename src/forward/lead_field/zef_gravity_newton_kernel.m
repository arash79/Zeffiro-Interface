function K = zef_gravity_newton_kernel(diff_vec, volume, field_type, directions)
%ZEF_GRAVITY_NEWTON_KERNEL  Newtonian gravity kernels (no G) at sensor rows.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   r = tet_centroid − sensor, one row per station. V is tet volume.
%   Coordinates and V must already be SI (metres, m^3). Multiply K by
%   G = 6.67408e-11 afterwards.
%
%   field_type
%     1  scalar  V (n·r)/||r||^3          (n · g)
%     2  vector  V (−n/||r||^3 + 3(n·r)r/||r||^5)
%                directional derivative of g = V r/||r||^3 wrt the station
%     3  scalar  V / ||r||                (Newtonian potential)
%     4  vector  V r / ||r||^3            (g)
%
%   Inherited code used sum(r.^2,2) for type 3 (that is ||r||^2, not ||r||)
%   and sum(r.^3,2) for type 4 (component cubes, not ||r||^3), type 1 /||r||^4,
%   and a dimensionally mixed type-2 second term.
%
%   K is n_stations×1 (types 1, 3) or n_stations×3 (types 2, 4).
%
%   See also zef_lead_field_gravity, zef_lead_field_gravity_grad.

arguments
    diff_vec (:, 3) double
    volume (1, 1) double
    field_type (1, 1) double {mustBeMember(field_type, [1 2 3 4])}
    directions (:, 3) double = zeros(0, 3)
end

r = sqrt(sum(diff_vec.^2, 2));
r = max(r, eps);

switch field_type
    case 3
        K = volume ./ r;
    case 4
        K = diff_vec .* (volume ./ (r.^3));
    case 1
        if size(directions, 1) ~= size(diff_vec, 1)
            error("Zeffiro:Gravity:MissingDirections", ...
                "Type 1 needs a unit direction row per station.");
        end
        ndotr = sum(directions .* diff_vec, 2);
        K = volume .* ndotr ./ (r.^3);
    case 2
        if size(directions, 1) ~= size(diff_vec, 1)
            error("Zeffiro:Gravity:MissingDirections", ...
                "Type 2 needs a unit direction row per station.");
        end
        ndotr = sum(directions .* diff_vec, 2);
        K = volume .* (-directions ./ (r.^3) + 3 * ndotr .* diff_vec ./ (r.^5));
end

end
