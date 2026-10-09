function strip_struct = zef_get_strip_parameters(strip_struct)
%ZEF_GET_STRIP_PARAMETERS  Fill strip_radius and strip_n_contacts from strip_model.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   strip_struct = zef_get_strip_parameters(strip_struct)
%
%   Model 1: 4 contacts, 2: 8, 3: 40, each with radius 0.635. Model 4
%   is the Shores 2026 DiSC-64 (radius 0.400, 64 active channels).
%   Model 5 is the Abrego 2023 G-128 wrap (radius 0.337, 128 channels).
%   The lattice is zef_strip_disc_lattice. Called from zef_create_strip
%   / embed / add_contacts. Does not write zef.
%
%   See also zef_create_strip, zef_strip_disc_site.

if isequal(strip_struct.strip_model,1)
strip_struct.strip_radius = 0.635;
strip_struct.strip_n_contacts = 4;
elseif isequal(strip_struct.strip_model,2)
strip_struct.strip_radius = 0.635;
strip_struct.strip_n_contacts = 8;
elseif isequal(strip_struct.strip_model,3)
strip_struct.strip_radius = 0.635;
strip_struct.strip_n_contacts = 40;
elseif ismember(strip_struct.strip_model, [4 5])
lattice = zef_strip_disc_lattice(strip_struct.strip_model);
strip_struct.strip_radius = lattice.shaft_radius;
strip_struct.strip_n_contacts = lattice.n_active;
end

end
