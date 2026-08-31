function [zef] = zef_turn_compartment_onoff(zef,compartment_onoff_vec)
%ZEF_TURN_COMPARTMENT_ONOFF  Set ON flags for all compartments from a vector.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Assigns zef.<compartment_tags{i}_on> = compartment_onoff_vec(i) for
%   each tag. When compartment_onoff_vec is empty, uses ones(1, n_tags).
%
%   zef = zef_turn_compartment_onoff(zef, compartment_onoff_vec)
%
%   Inputs
%     zef                   - session struct.
%     compartment_onoff_vec - numeric vector, one ON value per compartment tag.
%
%   Output
%     zef - session with updated _on fields.
%
%   See also zef_build_compartment_table.

c_t = zef.compartment_tags;
n_c_t = length(c_t);

if isempty(compartment_onoff_vec)
    compartment_onoff_vec = ones(1,n_c_t);
end

for i = 1 : n_c_t

    zef.([c_t{i} '_on']) = compartment_onoff_vec(i);

end

end
