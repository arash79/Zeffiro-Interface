% --- Zeffiro documentation header ---
% utilities.brainstorm2zef.zef_bst — Zef bst.
%
% Purpose:
%   Zef bst.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `utilities.brainstorm2zef.zef_bst` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef_bst.mesh_resolution = 3;
zef_bst.compartment_list = {'Scalp','OuterSkull','InnerSkull','Cortex','Other','white','subcortical'};
zef_bst.refine_surface = {'Scalp','OuterSkull','InnerSkull','Cortex','Other','white','subcortical'};
% Alternative compartment lists (commented out):
%zef_bst.compartment_list = {'Tissues','Deskian-Killiany','Thalamus'};
%zef_bst.refine_surface = {'Tissues','Deskian-Killiany'};

% Refinement settings
zef_bst.refine_surface_mode = 2; 

% Computation settings
zef_bst.use_gpu = 1;
zef_bst.parallel_processes = 10;
zef_bst.verbose_mode = 0;
zef_bst.use_waitbar = 1;

% Surface mesh settings
zef_bst.surface_mesh_density = 0.25;
zef_bst.distance_smoothing_exp = 2;
zef_bst.inflation_on = 0;
