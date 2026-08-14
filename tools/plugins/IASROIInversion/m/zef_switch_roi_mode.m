%ZEF_SWITCH_ROI_MODE  Enable sphere vs threshold ROI widgets from roi_mode.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. roi_mode dropdown. Value 1: sphere edits + plot ROI/source
%   on, threshold off. Else the reverse. Does not write iasroi_roi_mode
%   (the dropdown Callback does).
%
%   See also zef_iasroi_plot_roi.

if get(zef.h_iasroi_roi_mode,'value')==1;
    set(zef.h_iasroi_plot_roi,'enable','on');
    set(zef.h_iasroi_plot_source,'enable','on');
    set(zef.h_iasroi_roi_sphere_1,'enable','on');
    set(zef.h_iasroi_roi_sphere_2,'enable','on');
    set(zef.h_iasroi_roi_sphere_3,'enable','on');
    set(zef.h_iasroi_roi_sphere_4,'enable','on');
    set(zef.h_iasroi_rec_source_8,'enable','on');
    set(zef.h_iasroi_rec_source_9,'enable','on');
    set(zef.h_iasroi_roi_threshold,'enable','off');
else;
    set(zef.h_iasroi_roi_sphere_1,'enable','off');
    set(zef.h_iasroi_roi_sphere_2,'enable','off');
    set(zef.h_iasroi_roi_sphere_3,'enable','off');
    set(zef.h_iasroi_roi_sphere_4,'enable','off');
    set(zef.h_iasroi_rec_source_8,'enable','off');
    set(zef.h_iasroi_rec_source_9,'enable','off');
    set(zef.h_iasroi_plot_roi,'enable','off');
    set(zef.h_iasroi_plot_source,'enable','off');
end;
if get(zef.h_iasroi_roi_mode,'value')==2;
    set(zef.h_iasroi_roi_threshold,'enable','on');
else;
    set(zef.h_iasroi_roi_threshold,'enable','off');
end;
