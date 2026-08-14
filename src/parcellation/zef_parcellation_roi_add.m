function zef = zef_parcellation_roi_add(zef)
%ZEF_PARCELLATION_ROI_ADD  Prepend a default user-defined ROI to the ROI list.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Inserts center [0 0 0], radius 10, default color, and name
%   'Used-defined ROI' at the front of the ROI arrays, sets
%   parcellation_roi_selected to 1, and calls zef_update_parcellation.
%
%   zef = zef_parcellation_roi_add(zef)
%
%   See also zef_parcellation_roi_delete, zef_parcellation_roi_embed.

zef.parcellation_roi_selected = 1;
zef.parcellation_roi_center = [0 0 0; zef.parcellation_roi_center];
zef.parcellation_roi_radius = [10 zef.parcellation_roi_radius];
zef.parcellation_roi_color = [0.56078 0.91373 1; zef.parcellation_roi_color];
zef.parcellation_roi_name = [{'Used-defined ROI'} zef.parcellation_roi_name];
zef = zef_update_parcellation(zef);

end
