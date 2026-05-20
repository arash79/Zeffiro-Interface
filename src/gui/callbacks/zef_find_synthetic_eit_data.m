% ZEF_FIND_SYNTHETIC_EIT_DATA  Open and initialize the Find synthetic EIT data tool GUI.
%
% Loads the figure template from fig/tools/zef_find_synthetic_eit_data.fig
% (with fig/ on the MATLAB path), sets the window title and font scaling,
% runs the tool-specific initializer, and brings key controls to the front.
%
% The GUI is used to define synthetic EIT (electrical impedance tomography)
% data: ROI spheres, perturbation settings, and options to compute and plot
% the synthetic data.
%
% Copyright © 2018- Sampsa Pursiainen & ZI Development Team
% See: https://github.com/sampsapursiainen/zeffiro_interface

% Load the .fig template from fig/tools/ (path added at startup in zeffiro_interface.m).
if ismac
    zef.h_find_synthetic_source = open('zef_find_synthetic_eit_data.fig');
elseif ispc
    zef.h_find_synthetic_source = open('zef_find_synthetic_eit_data.fig');
else
    zef.h_find_synthetic_source = open('zef_find_synthetic_eit_data.fig');
end

% Set window title and scale fonts to match application settings.
set(zef.h_find_synthetic_source,'Name','ZEFFIRO Interface: Find synthetic EIT data');
set(findobj(zef.h_find_synthetic_source.Children,'-property','FontUnits'),'FontUnits','pixels');
set(findobj(zef.h_find_synthetic_source.Children,'-property','FontSize'),'FontSize',zef.font_size);

% Initialize tool-specific state and callbacks.
zef_init_find_synthetic_eit_data;

% Bring ROI and action controls to the top of the uistack for proper layering.
uistack(flipud([zef.h_inv_roi_sphere_1;  zef.h_inv_roi_sphere_2;
    zef.h_inv_roi_sphere_3; zef.h_inv_roi_sphere_4; zef.h_inv_roi_perturbation;
    zef.h_inv_compute_data; zef.h_inv_plot_roi ]),'top');
