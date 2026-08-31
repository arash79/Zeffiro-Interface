%ZEF_BST_DEFAULT  Script: overlay mesh/GPU fields onto workspace zef_bst.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not a function. zef_bst_get_settings('zef_bst_default') runs this after
%   zef_bst_init. Assigns mesh_resolution=3, compartment_list and
%   refine_surface (Scalp…subcortical), refine_surface_mode=2, use_gpu=1,
%   parallel_processes=10, verbose_mode=0, surface_mesh_density=0.25,
%   distance_smoothing_exp=2, inflation_on=0. Copy under a new name in
%   this folder for another preset.
%
%   See also zef_bst_init, zef_bst_get_settings.


zef_bst.mesh_resolution = 3;
zef_bst.compartment_list = {'Scalp','OuterSkull','InnerSkull','Cortex','Other','white','subcortical'};
zef_bst.refine_surface = {'Scalp','OuterSkull','InnerSkull','Cortex','Other','white','subcortical'};

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
