function compartment_settings = zef_bst_compartment_settings(zef_bst, surface_meshes)
%ZEF_BST_COMPARTMENT_SETTINGS Creates compartment settings array from Brainstorm surface meshes.
%
% This function generates a cell array containing compartment settings for
% each surface mesh, including refinement flags, electrical conductivity,
% and degree-of-freedom (DOF) space parameters.
%
% Inputs:
%   zef_bst       - Structure containing Brainstorm-to-Zeffiro configuration
%   surface_meshes - Structure array of surface meshes with fields:
%                    Name, Type, Points, Triangles
%
% Outputs:
%   compartment_settings - Cell array (Nx12) with columns:
%                          [1] 'Compartment name' header
%                          [2] Compartment name
%                          [3] 'Compartment type' header
%                          [4] Compartment type
%                          [5] 'Refine surface' header
%                          [6] Surface refinement flag (0 or 1)
%                          [7] 'Refine volume' header
%                          [8] Volume refinement flag (0 or 1)
%                          [9] 'Electrical conductivity' header
%                          [10] Electrical conductivity value
%                          [11] 'DOF space' header
%                          [12] DOF space value
%
% See also: ZEF_BST_CREATE_COMPARTMENT_DATA

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