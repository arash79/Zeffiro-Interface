function subcompartment_ind = zef_compartment_to_subcompartment(zef,compartment_ind)
%ZEF_COMPARTMENT_TO_SUBCOMPARTMENT  Map compartment indices to submesh index ranges.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   For each ON compartment in tag order, accumulates submesh_ind lengths
%   and returns the subcompartment index rows corresponding to the requested
%   compartment_ind vector.
%
%   subcompartment_ind = zef_compartment_to_subcompartment(zef, compartment_ind)
%
%   Inputs
%     zef              - session struct (read from base when empty).
%     compartment_ind  - compartment ordinal indices among ON compartments.
%
%   Output
%     subcompartment_ind - column vector of submesh row indices.
%
%   See also zef_process_meshes.

if isempty(zef)
    zef = evalin('base','zef');
end

compartment_tags = eval('zef.compartment_tags');

subcompartment_ind = [];

compartment_counter = 0;
subcompartment_counter = 0;

for i = 1 : length(compartment_tags)

    on_val = eval(['zef.' compartment_tags{i}  '_on']);

    if on_val
        submesh_ind = eval(['zef.' compartment_tags{i} '_submesh_ind']);
        compartment_counter = compartment_counter + 1;
        if ismember(compartment_counter,compartment_ind)
            subcompartment_ind = [subcompartment_ind ; [subcompartment_counter(end) + 1 : subcompartment_counter(end) + length(submesh_ind)]'];
        end
        subcompartment_counter = subcompartment_counter + length(submesh_ind);
    end
end

end
