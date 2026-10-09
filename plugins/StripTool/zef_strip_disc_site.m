function [angle, z_center, pitch, contact_radius] = zef_strip_disc_site(contact_index, strip_model, shaft_radius)
%ZEF_STRIP_DISC_SITE  One active DiSC channel on the shaft.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [angle, z_center, pitch, contact_radius] = ...
%       zef_strip_disc_site(contact_index, strip_model, shaft_radius)
%
%   contact_index counts active recording channels, not inactive
%   physical sites. The lattice is zef_strip_disc_lattice. pitch is
%   the active-row spacing and is not a license to retile the film.
%
%   See also zef_strip_disc_lattice, zef_get_strip_contacts.

if nargin < 3
    shaft_radius = [];
end
lattice = zef_strip_disc_lattice(strip_model, shaft_radius);
contact_index = double(contact_index);
if ~isscalar(contact_index) || contact_index ~= floor(contact_index) ...
        || contact_index < 1 || contact_index > lattice.n_active
    error('zef:DiscSite', ...
        'DiSC channel %s is outside the %d active channels.', ...
        mat2str(contact_index), lattice.n_active);
end

physical = lattice.active_physical(contact_index);
angle = lattice.angle(physical);
z_center = lattice.z_center(physical);
pitch = lattice.axial_pitch_mm;
contact_radius = lattice.contact_radius;

end
