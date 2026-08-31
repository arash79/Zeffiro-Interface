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
%   Model 1: 4 contacts, 2: 8, 3: 40. Radius always 0.635. Called from
%   zef_create_strip / embed / add_contacts. Does not write zef.
%
%   See also zef_create_strip.

if isequal(strip_struct.strip_model,1)
strip_struct.strip_radius = 0.635;
strip_struct.strip_n_contacts = 4;
elseif isequal(strip_struct.strip_model,2)
strip_struct.strip_radius = 0.635;
strip_struct.strip_n_contacts = 8;
elseif isequal(strip_struct.strip_model,3)
strip_struct.strip_radius = 0.635;
strip_struct.strip_n_contacts = 40;
end

end
