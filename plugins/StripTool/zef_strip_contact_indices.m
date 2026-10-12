function [active_index, inactive_index] = zef_strip_contact_indices(strip_struct)
%ZEF_STRIP_CONTACT_INDICES  Triangle rows of active and unwired contacts.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [active_index, inactive_index] = zef_strip_contact_indices(strip_struct)
%
%   strip_struct.points{1} is in the cylinder frame used by
%   zef_create_strip. DiSC models (4 and 5) also return the unwired
%   sites. Older shafts have no unwired sites. Does not write zef.
%
%   See also zef_strip_disc_patch, zef_get_strip_contacts.

active_index = zeros(0, 1);
inactive_index = zeros(0, 1);
if ~isstruct(strip_struct) || ~isfield(strip_struct, 'strip_model')
    return
end
if ~isfield(strip_struct, 'points') || isempty(strip_struct.points) || isempty(strip_struct.points{1})
    return
end
if ~isfield(strip_struct, 'triangles') || isempty(strip_struct.triangles) || isempty(strip_struct.triangles{1})
    return
end

if ismember(strip_struct.strip_model, [4 5])
    lattice = zef_strip_disc_lattice(strip_struct.strip_model, strip_struct.strip_radius);
    for physical = 1:lattice.n_physical
        triangle_index = zef_strip_disc_patch(strip_struct, physical);
        if isempty(triangle_index)
            continue
        end
        if lattice.active(physical)
            active_index = [active_index; triangle_index(:)]; %#ok<AGROW>
        else
            inactive_index = [inactive_index; triangle_index(:)]; %#ok<AGROW>
        end
    end
    return
end

if ~isfield(strip_struct, 'strip_n_contacts')
    return
end
for contact = 1:strip_struct.strip_n_contacts
    [~, ~, triangle_index] = zef_get_strip_contacts(contact, strip_struct, struct(), 'model_geometry');
    if ~isempty(triangle_index)
        active_index = [active_index; triangle_index(:)]; %#ok<AGROW>
    end
end
end
