function lattice = zef_strip_disc_lattice(strip_model, shaft_radius)
%ZEF_STRIP_DISC_LATTICE  Physical DiSC sites and the active-channel map.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   lattice = zef_strip_disc_lattice(strip_model)
%   lattice = zef_strip_disc_lattice(strip_model, shaft_radius)
%
%   Model 4 is the Shores et al. 2026 experimental DiSC-64
%   (bioRxiv 2026.06.11.731746): 128 physical contacts on a 0.800 mm
%   shaft, 64 of them wired. The film is 32 rows of 4, alternate rows
%   turned by 45 degrees. A diamond row is one pair of those rows.
%   Every other diamond is not connected. Model 5 is the fabricated
%   Abrego et al. 2023 G-128 wrap (J. Neural Eng. 20 016041; bioRxiv
%   2021.09.20.460996, Methods "128-ch DISC assembly"): 16 aligned rows
%   by 8 columns, all 128 channels active.
%
%   Angles are radians before strip_angle. z_center is millimetres
%   above the tip. Channel numbers are this lattice order, distal
%   ring first. They are not an Intan native-order map; Shores
%   measured that map per device and did not publish it.
%
%   See also zef_strip_disc_site, zef_strip_disc_patch.

if ~(isequal(strip_model, 4) || isequal(strip_model, 5))
    error('zef:DiscSite', ...
        'DiSC lattices are defined for strip models 4 and 5.');
end

design = local_design(strip_model);
if nargin < 2 || isempty(shaft_radius)
    shaft_radius = design.shaft_diameter_mm / 2;
end
shaft_radius = double(shaft_radius);
if ~isscalar(shaft_radius) || ~isfinite(shaft_radius) || shaft_radius <= 0
    error('zef:DiscSite', 'DiSC shaft radius must be a positive length.');
end

contact_radius = design.contact_diameter_mm / 2;
tip_clearance = contact_radius;
if isequal(strip_model, 5)
    [angle, z_center, active] = local_g128(shaft_radius, contact_radius, tip_clearance, design);
else
    [angle, z_center, active] = local_shores64(contact_radius, tip_clearance, design);
    local_require_column_clearance(shaft_radius, contact_radius);
end

channel = zeros(numel(active), 1);
channel(active) = (1:nnz(active))';
active_physical = find(active);

lattice = design;
lattice.shaft_radius = shaft_radius;
lattice.contact_radius = contact_radius;
lattice.tip_clearance = tip_clearance;
lattice.n_physical = numel(active);
lattice.n_active = nnz(active);
lattice.angle = angle;
lattice.z_center = z_center;
lattice.active = active;
lattice.channel = channel;
lattice.active_physical = active_physical;

local_require_separation(lattice);

end

function design = local_design(strip_model)

design = struct();
if isequal(strip_model, 5)
    % Abrego 2023 fabrication paragraph and Diagnostic Biochips 2024
    % catalog G128-1 (printed page 46): 16 x 8, 80 um sites, 200 um
    % vertical, 250 um horizontal, 3.00 mm by 1.75 mm center span.
    % Outer diameter is the assembled SS/PEBAX/resin/PI stack in
    % Abrego Suppl. Fig. 9 (674 um), not the 800 um idealized FEM
    % and not a diameter chosen to force 45 degree columns.
    design.design_id = 'abrego2023_g128';
    design.display_name = 'DiSC 128 (Abrego G-128)';
    design.shaft_diameter_mm = 0.674;
    design.contact_diameter_mm = 0.080;
    design.contact_diameter_status = 'measured_film';
    design.n_rows = 16;
    design.n_columns = 8;
    design.axial_pitch_mm = 0.200;
    design.arc_pitch_mm = 0.250;
    design.stagger_mm = 0;
    design.ring_pitch_mm = 0.200;
    design.arrangement = 'aligned_16x8';
else
    % Shores 2026 Fig. 1C, Fig. 3A and Fig. 7. The micrograph is a
    % uniform 32 by 4 film; alternate rows are shifted by half a
    % column. Fig. 7 states that the top and bottom four contacts of
    % one diamond row are 230 um apart, so that distance is the row
    % pitch. Eight active diamond rows remain after every other ring
    % of eight is left unwired. The 0.3 mm and 1.3 mm "rings" in that
    % paper are averages of one and two diamond rows, not pitches.
    % Fig. 1C also says the active array spans 7.5 mm; 29 row pitches
    % of 0.230 mm span 6.67 mm, and the scale bar on that panel agrees
    % with 0.230 mm rather than with 7.5 mm. The 80 um site diameter
    % is not stated by Shores. It is the G-128 / G64-6 catalog site
    % and is an assumption here, not Medani's 120 um pad.
    design.design_id = 'shores2026_disc64';
    design.display_name = 'DiSC 64 (Shores 2026)';
    design.shaft_diameter_mm = 0.800;
    design.contact_diameter_mm = 0.080;
    design.contact_diameter_status = 'assumed_parent_film';
    design.n_rows = 32;
    design.n_columns = 4;
    design.axial_pitch_mm = 0.920;
    design.arc_pitch_mm = [];
    design.stagger_mm = 0.230;
    design.ring_pitch_mm = 0.230;
    design.arrangement = 'staggered_32x4_eight_active_diamonds';
end

end

function [angle, z_center, active] = local_g128(shaft_radius, contact_radius, tip_clearance, design)

n_rows = design.n_rows;
n_columns = design.n_columns;
arc_pitch = design.arc_pitch_mm;
span = (n_columns - 1) * arc_pitch;
if span + 2 * contact_radius >= 2 * pi * shaft_radius
    error('zef:DiscSite', ...
        'DiSC shaft is too small for the 1.75 mm G-128 film span and 0.080 mm sites.');
end

n_physical = n_rows * n_columns;
angle = zeros(n_physical, 1);
z_center = zeros(n_physical, 1);
for row = 0:n_rows - 1
    for column = 0:n_columns - 1
        index = row * n_columns + column + 1;
        angle(index) = column * arc_pitch / shaft_radius;
        z_center(index) = tip_clearance + row * design.axial_pitch_mm;
    end
end
active = true(n_physical, 1);

end

function [angle, z_center, active] = local_shores64(contact_radius, tip_clearance, design)

n_rows = design.n_rows;
n_per_row = design.n_columns;
n_physical = n_rows * n_per_row;
angle = zeros(n_physical, 1);
z_center = zeros(n_physical, 1);
active = false(n_physical, 1);
for row = 0:n_rows - 1
    % Diamonds 0, 2, ... are wired. The distal diamond is the active
    % phase. Shores did not publish which phase was connected.
    diamond = floor(row / 2);
    row_active = mod(diamond, 2) == 0;
    for column = 0:n_per_row - 1
        index = row * n_per_row + column + 1;
        angle(index) = column * (pi / 2) + mod(row, 2) * (pi / 4);
        z_center(index) = tip_clearance + row * design.ring_pitch_mm;
        active(index) = row_active;
    end
end
if any(z_center - contact_radius < -1e-9)
    error('zef:DiscSite', 'A DiSC site lies below the tip.');
end

end

function local_require_column_clearance(shaft_radius, contact_radius)

% Four sites on a row are 90 degrees apart. The next row is turned by
% 45 degrees, so the nearest neighbour on the other half of a diamond
% is 45 degrees around the shaft.
gap = shaft_radius * (pi / 4);
if 2 * contact_radius >= gap
    error('zef:DiscSite', ...
        'DiSC-64 sites overlap around the shaft at this radius.');
end

end

function local_require_separation(lattice)

n = lattice.n_physical;
minimum = inf;
for index = 1:n - 1
    dtheta = atan2(sin(lattice.angle(index + 1:end) - lattice.angle(index)), ...
        cos(lattice.angle(index + 1:end) - lattice.angle(index)));
    arc = lattice.shaft_radius * dtheta;
    dz = lattice.z_center(index + 1:end) - lattice.z_center(index);
    minimum = min(minimum, min(hypot(arc, dz)));
end
if minimum <= 2 * lattice.contact_radius
    error('zef:DiscSite', 'DiSC sites overlap on the shaft.');
end

end
