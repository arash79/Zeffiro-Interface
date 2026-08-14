%ZEF_NSE_APPLY_NVC_SOURCE  DataTips → nse_field.nvc_source_x/y/z (NVC source location).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Same DataTip pattern as zef_nse_apply_source but writes nvc_source_*
%   and h_nvc_source_* (those handles are not created in
%   zef_nse_tool_window). Not a ButtonPushedFcn.
%
%   See also zef_nse_apply_source.
%

h_axes = gca;
if isempty(findobj(allchild(h_axes),'Type','DataTip'))~=1
    h_datatip = findobj(allchild(h_axes),'Type','DataTip');
    zef.nse_field.nvc_source_x = [];
    zef.nse_field.nvc_source_y = [];
    zef.nse_field.nvc_source_z = [];
    for i=1:size(h_datatip)
    zef.nse_field.nvc_source_x = [zef.nse_field.nvc_source_x h_datatip(i).X];
    zef.nse_field.nvc_source_y = [zef.nse_field.nvc_source_y h_datatip(i).Y];
    zef.nse_field.nvc_source_z = [zef.nse_field.nvc_source_z h_datatip(i).Z];
    end
    zef.nse_field.h_nvc_source_x.Value = num2str(zef.nse_field.nvc_source_x);
    zef.nse_field.h_nvc_source_y.Value = num2str(zef.nse_field.nvc_source_y);
    zef.nse_field.h_nvc_source_z.Value = num2str(zef.nse_field.nvc_source_z);

end
