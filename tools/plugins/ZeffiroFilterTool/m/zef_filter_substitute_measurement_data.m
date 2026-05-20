% --- Zeffiro documentation header ---
% [zef — [zef.
%
% Purpose:
%   [zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.processed_data (read)
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

[zef.yesno] = questdlg('Substitute raw data with processed data?','Yes','No');
if isequal(zef.yesno,'Yes');
    zef_filter_raw_data;

    zef.raw_data = zef.processed_data;

end;
