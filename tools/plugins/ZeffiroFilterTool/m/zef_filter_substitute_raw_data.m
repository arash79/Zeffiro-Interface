% --- Zeffiro documentation header ---
% [zef — [zef.
%
% Purpose:
%   [zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.filter_data_segment (read)
%   zef.measurements (read, write)
%   zef.processed_data (read)
%   zef.yesno (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `[zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

[zef.yesno] = questdlg('Substitute measurement data with processed data?','Yes','No');
if isequal(zef.yesno,'Yes');
    zef_filter_raw_data;

    if zef.filter_data_segment > 0
        if not(iscell(zef.measurements))
            zef.measurements = cell(0);
        end
        zef.measurements{zef.filter_data_segment} = zef.processed_data;
    else
        zef.measurements = zef.processed_data;
    end

end;
