function zef = zef_parcellation_roi_pick_center(zef)
%ZEF_PARCELLATION_ROI_PICK_CENTER  Copy figure datatip position into ROI center field.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   When a DataTip exists on zef.h_axes1, writes its X/Y/Z into
%   zef.parcellation_roi_center for parcellation_roi_selected and updates
%   the ROI center edit box string.
%
%   zef = zef_parcellation_roi_pick_center(zef)
%
%   See also zef_parcellation_roi_pick_color, zef_parcellation_roi_plot.

if isempty(findobj(allchild(zef.h_axes1),'Type','DataTip'))~=1
    zef.h_datatip = findobj(allchild(zef.h_axes1),'Type','DataTip');
    zef.parcellation_roi_center(zef.parcellation_roi_selected,:) = [h_datatip(1).X h_datatip(1).Y h_datatip(1).Z];
    zef.h_parcellation_roi_center.String = num2str(zef.parcellation_roi_center(zef.parcellation_roi_selected,:));
end

end
