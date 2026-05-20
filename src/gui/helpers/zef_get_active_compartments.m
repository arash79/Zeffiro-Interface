function [aux_compartment_ind, aux_brain_ind, property_compartment, property_brain] = zef_get_active_compartments(zef,varargin)
% --- Zeffiro documentation header ---
% zef_get_active_compartments — Zef get active compartments.
%
% Purpose:
%   Zef get active compartments.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   varargin
%
% Outputs:
%   aux_compartment_ind
%   aux_brain_ind
%   property_compartment
%   property_brain
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%
% Calls (project):
%   zef_get_active_compartments
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[aux_compartment_ind, aux_brain_ind, property_compartment]] = zef_get_active_compartments(zef, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
