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
%   zef.raw_data (read, write)
%   zef.yesno (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `[zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

[zef.yesno] = questdlg('Substitute raw data with measurement data?','Yes','No');
if isequal(zef.yesno,'Yes');

    if zef.filter_data_segment > 0
        if not(iscell(zef.measurements))
            zef.measurements = cell(0);
        end
        zef.raw_data = zef.measurements{zef.filter_data_segment};
    else
        zef.raw_data = zef.measurements;
    end

end;
