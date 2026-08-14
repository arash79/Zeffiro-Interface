function [aux_compartment_ind, aux_brain_ind, property_compartment, property_brain] = zef_get_active_compartments(zef,varargin)
%ZEF_GET_ACTIVE_COMPARTMENTS  Indices of On compartments and source tissues.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Walks zef.compartment_tags. A compartment is active if <tag>_on is true.
%   It is a "brain"/source compartment if <tag>_sources is 1 or 2 (not 0
%   inactive, not 3 PML-style). Optional property_name (e.g. 'name') returns
%   that field for each active / source compartment.
%
%   Callers: zef_find_relative_resolution; zef_open_forward_and_inverse_options
%   (names for the options dialog).
%
%   [comp_ind, brain_ind] = zef_get_active_compartments(zef)
%   [comp_ind, brain_ind, prop_comp, prop_brain] = ...
%       zef_get_active_compartments(zef, property_name)
%
%   Outputs are indices into compartment_tags (find of the filled slots).

property_name = cell(0);
property_compartment = cell(0);
property_brain = [];

if not(isempty(varargin))
    property_name = varargin{1};
end

compartment_tags = eval('zef.compartment_tags');

aux_compartment_ind = zeros(length(compartment_tags),1);
aux_brain_ind = zeros(length(compartment_tags),1);

i = 0;
length_reuna = 0;
sigma_vec = [];
priority_vec = [];
submesh_cell = cell(0);
for k = 1 : length(compartment_tags)

    var_0 = ['zef.'  compartment_tags{k} '_on'];
    var_1 = ['zef.' compartment_tags{k} '_sigma'];
    var_2 = ['zef.' compartment_tags{k} '_priority'];
    var_3 = ['zef.' compartment_tags{k} '_submesh_ind'];
    var_4 = ['zef.' compartment_tags{k} '_sources'];

    on_val = eval(var_0);
    sigma_val = eval(var_1);
    priority_val = eval(var_2);
    if on_val
        i = i + 1;
        sigma_vec(i,1) = sigma_val;
        priority_vec(i,1) = priority_val;
        submesh_cell{i} = eval(var_3);
        aux_compartment_ind(k) = i;

        if ismember(eval(var_4),[1 2])
            aux_brain_ind(k) = i;
        end

    end

end

aux_compartment_ind = find(aux_compartment_ind);
aux_brain_ind = find(aux_brain_ind);

if not(isempty(property_name))
    for i = 1 : length(aux_compartment_ind)
        property_compartment{i} = eval(['zef.' compartment_tags{aux_compartment_ind(i)} '_' property_name ';']);
    end
    for i = 1 : length(aux_brain_ind)
        property_brain{i} = eval(['zef.' compartment_tags{aux_brain_ind(i)} '_' property_name ';']);
    end
end
end
