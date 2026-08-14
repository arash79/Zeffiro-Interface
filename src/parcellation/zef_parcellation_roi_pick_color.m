function zef = zef_parcellation_roi_pick_color(zef)
%ZEF_PARCELLATION_ROI_PICK_COLOR  Choose ROI color via uisetcolor dialog.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Opens uisetcolor and, when not cancelled, updates
%   zef.parcellation_roi_color for parcellation_roi_selected and the ROI
%   color UI control background and string.
%
%   zef = zef_parcellation_roi_pick_color(zef)
%
%   See also zef_parcellation_roi_add.

color_vec = uisetcolor;
if not(isequal(color_vec,0))
    color_str = num2str(color_vec);
    zef.h_parcellation_roi_color.String = color_str;
    zef.h_parcellation_roi_color.BackgroundColor = color_vec;
    zef.parcellation_roi_color(zef.parcellation_roi_selected,:) = color_vec;
end

end
