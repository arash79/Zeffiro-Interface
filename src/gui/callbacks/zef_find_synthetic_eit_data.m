%ZEF_FIND_SYNTHETIC_EIT_DATA  Open the Find synthetic EIT data figure.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Forward tools → **Generate synthetic EIT data** opens
%   assets/fig/tools/zef_find_synthetic_eit_data.fig into
%   zef.h_find_synthetic_source, copies tagged h_* widgets onto zef,
%   runs zef_init_find_synthetic_eit_data, and wires Compute / Plot ROI.
%
%   See also zef_init_find_synthetic_eit_data, zef_synthetic_eit_data.

zef.h_find_synthetic_source = open('zef_find_synthetic_eit_data.fig');

set(zef.h_find_synthetic_source,'Name','ZEFFIRO Interface: Find synthetic EIT data');
zef_ui_ready(zef.h_find_synthetic_source);

h_all = findall(zef.h_find_synthetic_source);
for zef_i = 1 : numel(h_all)
    zef_tag = '';
    try
        zef_tag = strtrim(char(get(h_all(zef_i),'Tag')));
    catch
    end
    if startsWith(zef_tag,'h_')
        zef.(zef_tag) = h_all(zef_i);
    end
end

zef_init_find_synthetic_eit_data;

if isfield(zef,'h_inv_compute_data') && isgraphics(zef.h_inv_compute_data)
    try
        set(zef.h_inv_compute_data,'Callback','zef_update_find_synthetic_eit_data; zef_synthetic_eit_data;');
    catch
        set(zef.h_inv_compute_data,'ButtonPushedFcn','zef_update_find_synthetic_eit_data; zef_synthetic_eit_data;');
    end
end
if isfield(zef,'h_inv_plot_roi') && isgraphics(zef.h_inv_plot_roi)
    try
        set(zef.h_inv_plot_roi,'Callback','zef_update_find_synthetic_eit_data; zef_plot_roi;');
    catch
        set(zef.h_inv_plot_roi,'ButtonPushedFcn','zef_update_find_synthetic_eit_data; zef_plot_roi;');
    end
end

uistack(flipud([zef.h_inv_roi_sphere_1;  zef.h_inv_roi_sphere_2;
    zef.h_inv_roi_sphere_3; zef.h_inv_roi_sphere_4; zef.h_inv_roi_perturbation;
    zef.h_inv_compute_data; zef.h_inv_plot_roi ]),'top');
