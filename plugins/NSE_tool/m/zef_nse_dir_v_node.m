%ZEF_NSE_DIR_V_NODE  Apply dir_v button: DataTips → nse_field.dir_v_x/y/z.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ButtonPushedFcn of h_apply_dir_v. Script. The toward-point used by
%   zef_nse_vel_dir for wave-separation direction.
%
%   See also zef_nse_vel_dir, zef_nse_separate_waves_roi.
%

h_axes = gca;
if isempty(findobj(allchild(h_axes),'Type','DataTip'))~=1
    h_datatip = findobj(allchild(h_axes),'Type','DataTip');
    zef.nse_field.dir_v_x = [];
    zef.nse_field.dir_v_y = [];
    zef.nse_field.dir_v_z = [];
    for i=1:size(h_datatip,1)
    zef.nse_field.dir_v_x = [zef.nse_field.dir_v_x h_datatip(i).X];
    zef.nse_field.dir_v_y = [zef.nse_field.dir_v_y h_datatip(i).Y];
    zef.nse_field.dir_v_z = [zef.nse_field.dir_v_z h_datatip(i).Z];
    end
    zef.nse_field.h_dir_v_x.Value = num2str(zef.nse_field.dir_v_x);
    zef.nse_field.h_dir_v_y.Value = num2str(zef.nse_field.dir_v_y);
    zef.nse_field.h_dir_v_z.Value = num2str(zef.nse_field.dir_v_z);

end
