%ZEF_NSE_APPLY_SOURCE  Apply source coordinates: DataTips → nse_field.sphere_x/y/z.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ButtonPushedFcn of h_apply_source_coordinates. Script. DataTips on gca
%   become the grey-sphere centres used by solver_type 3 (pressure source
%   on the artery surface).
%
%   See also zef_nse_plot_sphere, zef_nse_haemodynamic_response_solver.
%

h_axes = gca;
if isempty(findobj(allchild(h_axes),'Type','DataTip'))~=1
    h_datatip = findobj(allchild(h_axes),'Type','DataTip');
    zef.nse_field.sphere_x = [];
    zef.nse_field.sphere_y = [];
    zef.nse_field.sphere_z = [];
    for i=1:size(h_datatip)
    zef.nse_field.sphere_x = [zef.nse_field.sphere_x h_datatip(i).X];
    zef.nse_field.sphere_y = [zef.nse_field.sphere_y h_datatip(i).Y];
    zef.nse_field.sphere_z = [zef.nse_field.sphere_z h_datatip(i).Z];
    end
    zef.nse_field.h_sphere_x.Value = num2str(zef.nse_field.sphere_x);
    zef.nse_field.h_sphere_y.Value = num2str(zef.nse_field.sphere_y);
    zef.nse_field.h_sphere_z.Value = num2str(zef.nse_field.sphere_z);

end
