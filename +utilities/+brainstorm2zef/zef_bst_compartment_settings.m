function compartment_settings = zef_bst_compartment_settings(zef_bst, surface_meshes)
%ZEF_BST_COMPARTMENT_SETTINGS  N-by-12 cell table: name, type, refine, sigma, DOF.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   compartment_settings = zef_bst_compartment_settings(zef_bst, surface_meshes)
%
%   One row per surface_meshes(i). Odd columns are labels; even columns:
%     2 Name, 4 Type, 6 refine-surface 0/1, 8 refine-volume 0/1,
%     10 conductivity (default 1), 12 DOF/activity (default 0).
%   Refine flags are 1 if Type or Name is in zef_bst.refine_surface /
%   refine_volume. Conductivity and DOF via zef_bst_get_compartment_property
%   on Type then Name against electrical_conductivity / dof_space.
%
%   See also zef_bst_create_compartment_data, zef_bst_get_compartment_property.

n_compartments = length(surface_meshes);

% Initialize compartment settings array with default values
compartment_settings = [repmat({'Compartment name'}, n_compartments,1), {surface_meshes.Name}',...
    repmat({'Compartment type'}, n_compartments,1), {surface_meshes.Type}', ... 
    repmat({'Refine surface'}, n_compartments,1), repmat({0}, n_compartments,1), ...
    repmat({'Refine volume'}, n_compartments,1), repmat({0}, n_compartments,1),...
    repmat({'Electrical conductivity'}, n_compartments,1), repmat({1}, n_compartments,1)...
    repmat({'DOF space'}, n_compartments,1), repmat({0}, n_compartments,1)];

% Process each compartment to set refinement flags and material properties
for i = 1 : n_compartments
    
    % Check if surface refinement is enabled for this compartment type or name
    if ismember(surface_meshes(i).Type, zef_bst.refine_surface)
        compartment_settings{i,6} = 1;
    end
    
    if ismember(surface_meshes(i).Name, zef_bst.refine_surface)
        compartment_settings{i,6} = 1;
    end
    
    % Check if volume refinement is enabled for this compartment type or name
    if ismember(surface_meshes(i).Type, zef_bst.refine_volume)
        compartment_settings{i,8} = 1;
    end
    
    if ismember(surface_meshes(i).Name, zef_bst.refine_volume)
        compartment_settings{i,8} = 1;
    end
    
    % Find electrical conductivity value matching compartment type or name
    % Try type first, then name
    conductivity = utilities.brainstorm2zef.zef_bst_get_compartment_property(...
        surface_meshes(i).Type, zef_bst.electrical_conductivity, 1.0);
    if isequal(conductivity, 1.0)
        % If default was returned, try with name
        conductivity = utilities.brainstorm2zef.zef_bst_get_compartment_property(...
            surface_meshes(i).Name, zef_bst.electrical_conductivity, 1.0);
    end
    compartment_settings{i,10} = conductivity;
    
    % Find DOF space value matching compartment type or name
    % Try type first, then name
    dof_space = utilities.brainstorm2zef.zef_bst_get_compartment_property(...
        surface_meshes(i).Type, zef_bst.dof_space, 0);
    if isequal(dof_space, 0) && ~ismember(surface_meshes(i).Type, zef_bst.dof_space(1:2:end))
        % If default was returned and type not found, try with name
        dof_space = utilities.brainstorm2zef.zef_bst_get_compartment_property(...
            surface_meshes(i).Name, zef_bst.dof_space, 0);
    end
    compartment_settings{i,12} = dof_space;
    
end

end
