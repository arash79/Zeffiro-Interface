%ZEF_NSE_APPLY_ROI  Apply ROI button: DataTips on h_axes1 → nse_field.roi_x/y/z and the ROI fields.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ButtonPushedFcn of h_apply_roi. Script (base-workspace zef). Copies
%   DataTip X/Y/Z into roi_* and the matching edit boxes. No-op if there
%   are no DataTips.
%
%   See also zef_nse_plot_roi, zef_nse_roi_ind.
%

% DataTips on h_axes1; loop uses h_datatip (not zef.h_datatip) as implemented.
if isempty(findobj(allchild(zef.h_axes1),'Type','DataTip'))~=1
    zef.h_datatip = findobj(allchild(zef.h_axes1),'Type','DataTip');
    zef.nse_field.roi_x = [];
    zef.nse_field.roi_y = [];
    zef.nse_field.roi_z = [];
    for i=1:size(zef.h_datatip,1)
    zef.nse_field.roi_x = [zef.nse_field.roi_x h_datatip(i).X];
    zef.nse_field.roi_y = [zef.nse_field.roi_y h_datatip(i).Y];
    zef.nse_field.roi_z = [zef.nse_field.roi_z h_datatip(i).Z];
    end
    zef.nse_field.h_roi_x.Value = num2str(zef.nse_field.roi_x);
    zef.nse_field.h_roi_y.Value = num2str(zef.nse_field.roi_y);
    zef.nse_field.h_roi_z.Value = num2str(zef.nse_field.roi_z);

end
