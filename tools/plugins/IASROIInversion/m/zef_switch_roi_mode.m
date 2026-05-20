% --- Zeffiro documentation header ---
% if get(zef — If get(zef.
%
% Purpose:
%   If get(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.h_iasroi_plot_roi (read)
%   zef.h_iasroi_plot_source (read)
%   zef.h_iasroi_rec_source_8 (read)
%   zef.h_iasroi_rec_source_9 (read)
%   zef.h_iasroi_roi_mode (read)
%   zef.h_iasroi_roi_sphere_1 (read)
%   zef.h_iasroi_roi_sphere_2 (read)
%   zef.h_iasroi_roi_sphere_3 (read)
%   zef.h_iasroi_roi_sphere_4 (read)
%   zef.h_iasroi_roi_threshold (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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
